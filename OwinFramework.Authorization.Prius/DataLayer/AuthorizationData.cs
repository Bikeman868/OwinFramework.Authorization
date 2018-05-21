using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using OwinFramework.Authorization.Core.Interfaces;
using OwinFramework.Authorization.Prius.DatabaseRecords;
using OwinFramework.Authorization.Prius.Poco;
using OwinFramework.InterfacesV1.Middleware;
using Prius.Contracts.Interfaces;
using Prius.Contracts.Interfaces.External;
using Urchin.Client.Interfaces;
using Group = OwinFramework.Authorization.Prius.DatabaseRecords.Group;

namespace OwinFramework.Authorization.Prius.DataLayer
{
    internal class AuthorizationData: 
        IAuthorizationData, 
        IFactory<IGroup>,
        IFactory<IPermission>,
        IFactory<IRole>
    {
        private readonly IContextFactory _contextFactory;
        private readonly ICommandFactory _commandFactory;
        private readonly IDisposable _configurationChangeRegistration;

        private string _repositoryWriterName;
        private string _repositoryReadonlyName;

        private string _defaultGroupName;
        private string _administratorsGroupName;
        private string _anonymousGroupName;

        private long? _defaultGroupId;
        private long? _administratorsGroupId;
        private long? _anonymousGroupId;

        private readonly Thread _reloadThread;
        private Dictionary<string, long> _identityGroupIds;
        private Dictionary<long, IdentityGroup> _groups;

        public AuthorizationData(
            IConfigurationStore configurationStore,
            IContextFactory contextFactory,
            ICommandFactory commandFactory)
        {
            _contextFactory = contextFactory;
            _commandFactory = commandFactory;

            _identityGroupIds = new Dictionary<string, long>();

            _configurationChangeRegistration = configurationStore.Register
                ("/OwinFramework/Authorization/Data",
                    c =>
                    {
                        var oldWriterName = _repositoryWriterName;
                        var oldReadonlyName = _repositoryReadonlyName;
                        try
                        {
                            _repositoryWriterName = c.PriusMasterRepository;
                            _repositoryReadonlyName = c.PriusReadonlyReplicaRepository;
                            _defaultGroupName = string.Intern(c.DefaultGroup.ToLower());
                            _administratorsGroupName = string.Intern(c.AdministratorGroup.ToLower());
                            _anonymousGroupName = string.Intern(c.AnonymousGroup.ToLower());
                            Reload();
                        }
                        catch
                        {
                            _repositoryWriterName = oldWriterName;
                            _repositoryReadonlyName = oldReadonlyName;
                        }
                    },
                new DataLayerConfiguration());

            _reloadThread = new Thread(() => 
            {
                while (true)
                {
                    try
                    {
                        Thread.Sleep(TimeSpan.FromMinutes(1));
                        Reload();
                    }
                    catch (ThreadAbortException)
                    {
                        return;
                    }
                    catch
                    {
                        Thread.Sleep(TimeSpan.FromMinutes(5));
                    }
                }
            }) 
            {
                Priority = ThreadPriority.BelowNormal, 
                Name = "Reload permissions", 
                IsBackground = true
            };

            _reloadThread.Start();
        }

        #region Caching and testing permissions

        private void Reload()
        {
            var groups = new Dictionary<long, IdentityGroup>();

            foreach (var group in GetGroups())
            {
                groups[group.Id] = new IdentityGroup
                {
                    GroupId = group.Id,
                    CodeName = string.Intern(group.CodeName.ToLower()),
                    IdentityRoles = GetGroupRoles(group.Id)
                        .Select(r => new IdentityRole
                        {
                            RoleId = r.Id,
                            CodeName = string.Intern(r.CodeName.ToLower()),
                            IdentityPermissions = GetRolePermissions(r.Id)
                                .Select(p => new IdentityPermission
                                {
                                    PermissionId = p.Id,
                                    CodeName = string.Intern(p.CodeName.ToLower()),
                                    Resource = p.Resource
                                })
                                .ToArray()
                        })
                        .ToArray(),
                    IdentityPermissions = GetGroupPermissions(group.Id)
                        .Select(p => new IdentityPermission 
                        { 
                            PermissionId = p.Id,
                            CodeName = string.Intern(p.CodeName.ToLower()),
                            Resource = p.Resource
                        })
                        .ToArray()
                };

                if (group.CodeName == _defaultGroupName)
                    _defaultGroupId = group.Id;

                if (group.CodeName == _administratorsGroupName)
                    _administratorsGroupId = group.Id;

                if (group.CodeName == _anonymousGroupName)
                    _anonymousGroupId = group.Id;
            }

            _groups = groups;
            _identityGroupIds = new Dictionary<string, long>();
        }

        public long? FindGroup(IIdentification identification)
        {
            var group = FindIdentityGroup(identification);
            return group == null ? (long?)null : group.GroupId;
        }

        private IdentityGroup FindIdentityGroup(IIdentification identification)
        {
            var groupId = (long?)null;

            if (identification == null || identification.IsAnonymous)
            {
                groupId = _anonymousGroupId;
            }
            else
            {
                lock (_identityGroupIds)
                {
                    long id;
                    if (_identityGroupIds.TryGetValue(identification.Identity, out id))
                        groupId = id;
                }

                if (!groupId.HasValue)
                    groupId = GetGroupId(identification);

                if (!groupId.HasValue)
                    groupId = _defaultGroupId;

                if (groupId.HasValue)
                {
                    lock (_identityGroupIds)
                    {
                        _identityGroupIds[identification.Identity] = groupId.Value;
                    }
                }
            }

            if (!groupId.HasValue)
                return null;

            IdentityGroup identityGroup;
            lock(_groups)
                _groups.TryGetValue(groupId.Value, out identityGroup);
            return identityGroup;
        }

        public void GetIdentity(IIdentification identification, out Core.DataContracts.Group group, out List<string> roles, out List<string> permissions)
        {
            var identityGroup = FindIdentityGroup(identification);

            group = GetGroup(identityGroup.GroupId);

            roles = identityGroup.IdentityRoles
                .Select(r => r.CodeName)
                .ToList();

            permissions = identityGroup.IdentityPermissions
                .Select(p => string.IsNullOrEmpty(p.Resource) ? p.CodeName : p.CodeName + " on " + p.Resource)
                .ToList();
        }

        public bool IsInRole(IIdentification identification, string roleCodeName)
        {
            var group = FindIdentityGroup(identification);
            if (group == null) return false;

            var internedRoleName = string.Intern(roleCodeName.ToLower());
            if (!group.IdentityRoles.Any(r => r.CodeName == internedRoleName))
                return false;

            if (identification.Purposes == null || identification.Purposes.Count == 0)
                return true;

            return identification.Purposes.Any(p => string.Intern(p.ToLower()) == internedRoleName);
        }

        public bool HasPermission(IIdentification identification, string permissionCodeName, string resourceName)
        {
            var group = FindIdentityGroup(identification);
            if (group == null) return false;

            if (group.GroupId == _administratorsGroupId) return true;

            var internedPermissionName = string.Intern(permissionCodeName.ToLower());

            IEnumerable<IdentityPermission> permissions;

            if (identification.Purposes == null || identification.Purposes.Count == 0)
            {
                permissions = group.IdentityPermissions.Where(p => p.CodeName == internedPermissionName);
            }
            else
            {
                var purposeNames = identification
                    .Purposes
                    .Select(p => string.Intern(p.ToLower()))
                    .ToList();

                var roles = group
                    .IdentityRoles
                    .Where(r => purposeNames.Contains(r.CodeName))
                    .ToList();

                permissions = roles.Aggregate(new List<IdentityPermission>(), (l, r) =>
                {
                    l.AddRange(r.IdentityPermissions.Where(p => p.CodeName == internedPermissionName));
                    return l;
                });
            }

            if (string.IsNullOrEmpty(resourceName))
                return permissions.Any();

            return permissions.Any(p => IsResourceMatch(resourceName, p.Resource, identification, group));
        }

        private bool IsResourceMatch(string resourceName, string expression, IIdentification identification, IdentityGroup group)
        {
            if (string.IsNullOrEmpty(expression)) return true;
            if (string.IsNullOrEmpty(resourceName)) return true;

            var resourceColonPos = resourceName.IndexOf(':');
            var expressionColonPos = expression.IndexOf(':');
            if (resourceColonPos != expressionColonPos) return false;

            if (resourceColonPos >= 0)
            {
                if (!string.Equals(resourceName.Substring(0, resourceColonPos), expression.Substring(0, expressionColonPos))) 
                    return false;
                resourceName = resourceName.Substring(resourceColonPos + 1);
                expression = expression.Substring(expressionColonPos + 1);
            }

            var resourcePath = resourceName.Split('/');
            var expressionPath = expression.Split('/');

            if (expressionPath.Length > resourcePath.Length) return false;

            for (var i = 0; i < expressionPath.Length; i++)
            {
                var expressionElement = expressionPath[i];
                if (expressionElement.Length == 0) return false;
                if (expressionElement[0] == '*') continue;
                if (expressionElement[0] == '{')
                {
                    switch (expressionElement.ToLower())
                    {
                        case "{my.id}":
                            expressionElement = identification.Identity;
                            break;
                        case "{my.group}":
                            expressionElement = group.CodeName;
                            break;
                        case "{my.role}":
                            if (group.IdentityRoles.Any(r => string.Equals(r.CodeName, resourcePath[i], StringComparison.InvariantCultureIgnoreCase)))
                                continue;
                            return false;
                        case "{my.permission}":
                            if (group.IdentityPermissions.Any(p => string.Equals(p.CodeName, resourcePath[i], StringComparison.InvariantCultureIgnoreCase)))
                                continue;
                            return false;
                        case "{my.username}":
                            expressionElement = identification
                                .Claims
                                .Where(c => c.Name == ClaimNames.Username)
                                .Select(c => c.Value)
                                .FirstOrDefault();
                            break;
                        case "{my.email}":
                            expressionElement = identification
                                .Claims
                                .Where(c => c.Name == ClaimNames.Email)
                                .Select(c => c.Value)
                                .FirstOrDefault();
                            break;
                        case "{my.ipv4}":
                            expressionElement = identification
                                .Claims
                                .Where(c => c.Name == ClaimNames.IpV4)
                                .Select(c => c.Value)
                                .FirstOrDefault();
                            break;
                        case "{my.ipv6}":
                            expressionElement = identification
                                .Claims
                                .Where(c => c.Name == ClaimNames.IpV6)
                                .Select(c => c.Value)
                                .FirstOrDefault();
                            break;
                    }
                }
                if (!string.Equals(expressionElement, resourcePath[i]))
                    return false;
            }

            return true;
        }

        #endregion

        #region Stored procedure wrappers

        public Core.DataContracts.Group GetGroup(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroup"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Group;
                    }
                }
            }
        }

        public Core.DataContracts.Group GetGroup(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Group;
                    }
                }
            }
        }

        public IList<Core.DataContracts.Group> GetGroups(Func<Core.DataContracts.Group, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroups"))
                {
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        var groups = results.Cast<Core.DataContracts.Group>();
                        return filterFunction == null
                            ? groups.ToList()
                            : groups.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Core.DataContracts.Role GetRole(long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRole"))
                {
                    command.AddParameter("roleId", roleId);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Role;
                    }
                }
            }
        }

        public Core.DataContracts.Role GetRole(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRoleByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Role;
                    }
                }
            }
        }

        public IList<Core.DataContracts.Role> GetRoles(Func<Core.DataContracts.Role, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRoles"))
                {
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        var roles = results.Cast<Core.DataContracts.Role>();
                        return filterFunction == null
                            ? roles.ToList()
                            : roles.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Core.DataContracts.Permission GetPermission(long permissionId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermission"))
                {
                    command.AddParameter("permissionId", permissionId);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Permission;
                    }
                }
            }
        }

        public Core.DataContracts.Permission GetPermission(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermissionByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results
                            .Cast<Core.DataContracts.Permission>()
                            .FirstOrDefault(p => string.IsNullOrEmpty(p.Resource));
                    }
                }
            }
        }

        public IList<Core.DataContracts.Permission> GetPermissions(Func<Core.DataContracts.Permission, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermissions"))
                {
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        var permissions = results.Cast<Core.DataContracts.Permission>();
                        return filterFunction == null
                            ? permissions.ToList()
                            : permissions.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Core.DataContracts.Group NewGroup(Core.DataContracts.Group group)
        {
            Validate(group);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddGroup"))
                {
                    command.AddParameter("groupCodeName", group.CodeName);
                    command.AddParameter("groupDisplayName", group.DisplayName);
                    command.AddParameter("groupDescription", group.Description);
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Group;
                    }
                }
            }
        }

        public Core.DataContracts.Role NewRole(Core.DataContracts.Role role)
        {
            Validate(role);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddRole"))
                {
                    command.AddParameter("roleCodeName", role.CodeName);
                    command.AddParameter("roleDisplayName", role.DisplayName);
                    command.AddParameter("roleDescription", role.Description);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Role;
                    }
                }
            }
        }

        public Core.DataContracts.Permission NewPermission(Core.DataContracts.Permission permission)
        {
            Validate(permission);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddPermission"))
                {
                    command.AddParameter("permissionCodeName", permission.CodeName);
                    command.AddParameter("permissionResource", permission.Resource);
                    command.AddParameter("permissionDisplayName", permission.DisplayName);
                    command.AddParameter("permissionDescription", permission.Description);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Permission;
                    }
                }
            }
        }

        public Core.DataContracts.Permission EnsurePermission(Core.DataContracts.Permission permission)
        {
            if (string.IsNullOrEmpty(permission.Resource))
            {
                var existing = GetPermission(permission.CodeName);
                if (existing != null) return existing;
            }
            else
            {
                var existing = GetPermissions(p => 
                    string.Equals(p.CodeName, permission.CodeName, StringComparison.InvariantCultureIgnoreCase) &&
                    string.Equals(p.Resource, permission.Resource, StringComparison.InvariantCultureIgnoreCase))
                    .FirstOrDefault();
                if (existing != null) return existing;
            }

            return NewPermission(permission);
        }

        public Core.DataContracts.Group UpdateGroup(Core.DataContracts.Group group)
        {
            Validate(group);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_UpdateGroup"))
                {
                    command.AddParameter("groupId", group.Id);
                    command.AddParameter("groupCodeName", group.CodeName);
                    command.AddParameter("groupDisplayName", group.DisplayName);
                    command.AddParameter("groupDescription", group.Description);
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Group;
                    }
                }
            }
        }

        public Core.DataContracts.Role UpdateRole(Core.DataContracts.Role role)
        {
            Validate(role);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_UpdateRole"))
                {
                    command.AddParameter("roleId", role.Id);
                    command.AddParameter("roleCodeName", role.CodeName);
                    command.AddParameter("roleDisplayName", role.DisplayName);
                    command.AddParameter("roleDescription", role.Description);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Role;
                    }
                }
            }
        }

        public Core.DataContracts.Permission UpdatePermission(Core.DataContracts.Permission permission)
        {
            Validate(permission);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_UpdatePermission"))
                {
                    command.AddParameter("permissionId", permission.Id);
                    command.AddParameter("permissionCodeName", permission.CodeName);
                    command.AddParameter("permissionResource", permission.Resource);
                    command.AddParameter("permissionDisplayName", permission.DisplayName);
                    command.AddParameter("permissionDescription", permission.Description);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Permission;
                    }
                }
            }
        }

        public void DeleteGroup(long groupToDelete, long reassignIdentitiesTo)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteGroup"))
                {
                    command.AddParameter("groupId", groupToDelete);
                    command.AddParameter("replacementGroupId", reassignIdentitiesTo);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void DeleteRole(long roleToDelete)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRole"))
                {
                    command.AddParameter("roleId", roleToDelete);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void DeletePermission(long permissionToDelete)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeletePermission"))
                {
                    command.AddParameter("permissionId", permissionToDelete);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public IList<Core.DataContracts.Role> GetGroupRoles(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupRoles"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.Cast<Core.DataContracts.Role>().ToList();
                    }
                }
            }
        }

        public IList<Core.DataContracts.Permission> GetRolePermissions(long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRolePermissions"))
                {
                    command.AddParameter("roleId", roleId);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.Cast<Core.DataContracts.Permission>().ToList();
                    }
                }
            }
        }

        public IList<Core.DataContracts.Permission> GetGroupPermissions(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupPermissions"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.Cast<Core.DataContracts.Permission>().ToList();
                    }
                }
            }
        }

        public long? GetIdentityGroupId(string identity)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityGroupId"))
                {
                    command.AddParameter("identity", identity);
                    return context.ExecuteScalar<long?>(command);
                }
            }
        }

        public long? GetGroupId(IIdentification identification)
        {
            return GetIdentityGroupId(identification.Identity);
        }

        public Core.DataContracts.Group GetGroup(IIdentification identification)
        {
            var groupId = GetGroupId(identification);
            if (!groupId.HasValue) return null;

            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroup"))
                {
                    command.AddParameter("groupId", groupId.Value);
                    using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                    {
                        return results.FirstOrDefault() as Core.DataContracts.Group;
                    }
                }
            }
        }

        public IList<Core.DataContracts.Role> GetRoles(IIdentification identification)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityRoles"))
                {
                    command.AddParameter("identity", identification.Identity);
                    using (var results = context.ExecuteEnumerable<IRole>(command, null, this))
                    {
                        return results.Cast<Core.DataContracts.Role>().ToList();
                    }
                }
            }
        }

        public IList<Core.DataContracts.Permission> GetPermissions(IIdentification identification)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityPermissions"))
                {
                    command.AddParameter("identity", identification.Identity);
                    using (var results = context.ExecuteEnumerable<IPermission>(command, null, this))
                    {
                        return results.Cast<Core.DataContracts.Permission>().ToList();
                    }
                }
            }
        }

        public Core.DataContracts.Group ChangeGroup(IIdentification identification, long? groupId)
        {
            try
            {
                using (var context = _contextFactory.Create(_repositoryWriterName))
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_ChangeIdentityGroup"))
                    {
                        command.AddParameter("identity", identification.Identity);
                        command.AddParameter("groupId", groupId);
                        using (var results = context.ExecuteEnumerable<IGroup>(command, null, this))
                        {
                            return results.FirstOrDefault() as Core.DataContracts.Group;
                        }
                    }
                }
            }
            finally
            {
                lock (_identityGroupIds)
                    _identityGroupIds.Remove(identification.Identity.ToLower());
            }
        }

        public void AddRoleToGroup(long roleId, long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddGroupRole"))
                {
                    command.AddParameter("roleId", roleId);
                    command.AddParameter("groupId", groupId);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void AddPermissionToRole(long permissionId, long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddRolePermission"))
                {
                    command.AddParameter("roleId", roleId);
                    command.AddParameter("permissionId", permissionId);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void RemoveRoleFromGroup(long roleId, long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteGroupRole"))
                {
                    command.AddParameter("roleId", roleId);
                    command.AddParameter("groupId", groupId);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public void RemovePermissionFromRole(long permissionId, long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRolePermission"))
                {
                    command.AddParameter("roleId", roleId);
                    command.AddParameter("permissionId", permissionId);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        public IList<Tuple<long, long>> GetAllGroupRoles()
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetAllGroupRoles"))
                {
                    using (var reader = context.ExecuteReader(command))
                    {
                        var result = new List<Tuple<long, long>>();
                        while (reader.Read())
                        {
                            result.Add(new Tuple<long, long>(reader.Get<long>(0), reader.Get<long>(1)));
                        }
                        return result;
                    }
                }
            }
        }

        public IList<Tuple<long, long>> GetAllRolePermissions()
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetAllRolePermissions"))
                {
                    using (var reader = context.ExecuteReader(command))
                    {
                        var result = new List<Tuple<long, long>>();
                        while (reader.Read())
                        {
                            result.Add(new Tuple<long, long>(reader.Get<long>(0), reader.Get<long>(1)));
                        }
                        return result;
                    }
                }
            }
        }

        #endregion

        #region Validation

        private readonly Regex _nameRegex = new Regex("^[a-z0-9_\\-.@]+$", RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);
        private readonly Regex _permissionNameRegex = new Regex("^[a-z0-9_\\-.@]+(:[a-z0-9_\\-.@]+)?$", RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);
        private readonly Regex _resourceRegex = new Regex("^[a-z0-9_\\-.]+:[a-z0-9_\\-.@/]+$", RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);
        private readonly Regex _resourceMatchRegex = new Regex("^[a-z0-9_\\-.]+:(\\*|{[a-z\\.]+}|[a-z0-9_\\-.@]+)(/(\\*|{[a-z\\.]+}|[a-z0-9_\\-.@]+))*$", RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);

        public void Validate(Core.DataContracts.Group group)
        {
            if (group.CodeName == null || group.CodeName.Length > 30 || group.CodeName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Group code name length must be between 1 and 30 characters");

            if (!_nameRegex.IsMatch(group.CodeName))
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Group code name must match " + _nameRegex);

            if (group.DisplayName == null || group.DisplayName.Length > 50 || group.DisplayName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Group display name length must be between 1 and 50 characters");
        }

        public void Validate(Core.DataContracts.Role role)
        {
            if (role.CodeName == null || role.CodeName.Length > 30 || role.CodeName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Role code name length must be between 1 and 30 characters");

            if (!_nameRegex.IsMatch(role.CodeName))
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Role code name must match " + _nameRegex);

            if (role.DisplayName == null || role.DisplayName.Length > 50 || role.DisplayName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Role display name length must be between 1 and 50 characters");
        }

        public void Validate(Core.DataContracts.Permission permission)
        {
            if (permission.CodeName == null || permission.CodeName.Length > 80 || permission.CodeName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Permission code name length must be between 1 and 80 characters");

            if (!_permissionNameRegex.IsMatch(permission.CodeName))
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Permission code name must match " + _permissionNameRegex);

            if (!string.IsNullOrEmpty(permission.Resource))
            {
                if (permission.Resource.Length > 120)
                    throw new HttpException((int)HttpStatusCode.BadRequest,
                        "Permission resource expression can not exceed 120 characters");

                if (!_resourceMatchRegex.IsMatch(permission.Resource))
                    throw new HttpException((int)HttpStatusCode.BadRequest,
                        "Permission resource expression must match " + _resourceMatchRegex);
            }

            if (permission.DisplayName == null || permission.DisplayName.Length > 50 || permission.DisplayName.Length < 1)
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "Permission display name length must be between 1 and 50 characters");
        }

        #endregion

        #region Record factory methods

        IGroup global::Prius.Contracts.Interfaces.External.IFactory<IGroup>.Create()
        {
            return new Group();
        }

        IPermission global::Prius.Contracts.Interfaces.External.IFactory<IPermission>.Create()
        {
            return new Permission();
        }

        IRole global::Prius.Contracts.Interfaces.External.IFactory<IRole>.Create()
        {
            return new Role();
        }

        #endregion;
    }
}
