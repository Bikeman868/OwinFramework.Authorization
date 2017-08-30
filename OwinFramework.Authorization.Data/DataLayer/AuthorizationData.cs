using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.Authorization.Data.Interfaces;
using OwinFramework.InterfacesV1.Middleware;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;
using Group = OwinFramework.Authorization.Data.DataContracts.Group;

namespace OwinFramework.Authorization.Data.DataLayer
{
    internal class AuthorizationData: IAuthorizationData
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
                        Thread.Sleep(TimeSpan.FromSeconds(10));
                    }
                }
            });

            _reloadThread.Priority = ThreadPriority.BelowNormal;
            _reloadThread.Name = "Reload permissions";
            _reloadThread.IsBackground = true;
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

        private IdentityGroup FindGroup(IIdentification identification)
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

        public void GetIdentity(IIdentification identification, out string group, out List<string> roles, out List<string> permissions)
        {
            var identityGroup = FindGroup(identification);

            group = identityGroup.CodeName;

            roles = identityGroup.IdentityRoles
                .Select(r => r.CodeName)
                .ToList();

            permissions = identityGroup.IdentityPermissions
                .Select(p => string.IsNullOrEmpty(p.Resource) ? p.CodeName : p.CodeName + " on " + p.Resource)
                .ToList();
        }

        public bool IsInRole(IIdentification identification, string roleCodeName)
        {
            var group = FindGroup(identification);
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
            var group = FindGroup(identification);
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

        public Group GetGroup(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroup"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Group GetGroup(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public IEnumerable<Group> GetGroups(Func<Group, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroups"))
                {
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return filterFunction == null
                            ? results.ToList()
                            : results.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Role GetRole(long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRole"))
                {
                    command.AddParameter("roleId", roleId);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Role GetRole(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRoleByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public IEnumerable<Role> GetRoles(Func<Role, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRoles"))
                {
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return filterFunction == null
                            ? results.ToList()
                            : results.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Permission GetPermission(long permissionId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermission"))
                {
                    command.AddParameter("permissionId", permissionId);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Permission GetPermission(string codeName)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermissionByCodeName"))
                {
                    command.AddParameter("codeName", codeName);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public IEnumerable<Permission> GetPermissions(Func<Permission, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetPermissions"))
                {
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return filterFunction == null
                            ? results.ToList()
                            : results.Where(filterFunction).ToList();
                    }
                }
            }
        }

        public Group NewGroup(Group group)
        {
            Validate(group);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddGroup"))
                {
                    command.AddParameter("groupCodeName", group.CodeName);
                    command.AddParameter("groupDisplayName", group.DisplayName);
                    command.AddParameter("groupDescription", group.Description);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Role NewRole(Role role)
        {
            Validate(role);

            using (var context = _contextFactory.Create(_repositoryWriterName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddRole"))
                {
                    command.AddParameter("roleCodeName", role.CodeName);
                    command.AddParameter("roleDisplayName", role.DisplayName);
                    command.AddParameter("roleDescription", role.Description);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Permission NewPermission(Permission permission)
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
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Group UpdateGroup(Group group)
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
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Role UpdateRole(Role role)
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
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Permission UpdatePermission(Permission permission)
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
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.FirstOrDefault();
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

        public IEnumerable<Role> GetGroupRoles(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupRoles"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public IEnumerable<Permission> GetRolePermissions(long roleId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetRolePermissions"))
                {
                    command.AddParameter("roleId", roleId);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public IEnumerable<Permission> GetGroupPermissions(long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroupPermissions"))
                {
                    command.AddParameter("groupId", groupId);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public long? GetGroupId(IIdentification identification)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityGroupId"))
                {
                    command.AddParameter("identity", identification.Identity);
                    return context.ExecuteScalar<long?>(command);
                }
            }
        }

        public Group GetGroup(IIdentification identification)
        {
            var groupId = GetGroupId(identification);
            if (!groupId.HasValue) return null;

            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetGroup"))
                {
                    command.AddParameter("groupId", groupId.Value);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public IEnumerable<Role> GetRoles(IIdentification identification)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityRoles"))
                {
                    command.AddParameter("identity", identification.Identity);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public IEnumerable<Permission> GetPermissions(IIdentification identification)
        {
            using (var context = _contextFactory.Create(_repositoryReadonlyName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityPermissions"))
                {
                    command.AddParameter("identity", identification.Identity);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public Group ChangeGroup(IIdentification identification, long groupId)
        {
            try
            {
                using (var context = _contextFactory.Create(_repositoryWriterName))
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_ChangeIdentityGroup"))
                    {
                        command.AddParameter("identity", identification.Identity);
                        command.AddParameter("groupId", groupId);
                        using (var results = context.ExecuteEnumerable<Group>(command))
                        {
                            return results.FirstOrDefault();
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

        public IEnumerable<Tuple<long, long>> GetAllGroupRoles()
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

        public IEnumerable<Tuple<long, long>> GetAllRolePermissions()
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

        public void Validate(Group group)
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

        public void Validate(Role role)
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

        public void Validate(Permission permission)
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
    }
}
