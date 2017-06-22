using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.Authorization.Data.Interfaces;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;

namespace OwinFramework.Authorization.Data.DataLayer
{
    internal class AuthorizationData: IAuthorizationData
    {
        private readonly IContextFactory _contextFactory;
        private readonly ICommandFactory _commandFactory;
        private readonly IDisposable _configurationChangeRegistration;
        private string _repositoryName;
        private string _defaultGroupName;
        private string _administratorsGroupName;
        private long? _defaultGroupId;
        private long? _administratorsGroupId;

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
            _configurationChangeRegistration = configurationStore.Register
                ("/OwinFramework/Authorization/Data",
                    c =>
                    {
                        var oldName = _repositoryName;
                        try
                        {
                            _repositoryName = c.PriusRepositoryName;
                            _defaultGroupName = string.Intern(c.DefaultGroup.ToLower());
                            _administratorsGroupName = string.Intern(c.AdministratorGroup.ToLower());
                            Reload();
                        }
                        catch
                        {
                            _repositoryName = oldName;
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
                    catch (ThreadAbortException ex)
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
                    CodeName = group.CodeName,
                    IdentityRoles = GetGroupRoles(group.Id)
                        .Select(r => new IdentityRole
                        {
                            RoleId = r.Id,
                            CodeName = string.Intern(r.CodeName.ToLower())
                        })
                        .ToArray(),
                    IdentityPermissions = GetGroupPermissions(group.Id)
                        .Select(p => new IdentityPermission 
                        { 
                            PermissionId = p.Id,
                            CodeName = string.Intern(p.CodeName.ToLower())
                        })
                        .ToArray()
                };
                if (string.Equals(group.DisplayName, _defaultGroupName, StringComparison.InvariantCultureIgnoreCase))
                    _defaultGroupId = group.Id;
                if (string.Equals(group.DisplayName, _administratorsGroupName, StringComparison.InvariantCultureIgnoreCase))
                    _administratorsGroupId = group.Id;
            }

            _groups = groups;
            _identityGroupIds = new Dictionary<string, long>();
        }

        private IdentityGroup FindIdentityGroup(string identity)
        {
            if (string.IsNullOrEmpty(identity))
                return null;

            var groupId = (long?)null;
            lock (_identityGroupIds)
            {
                long id;
                if (_identityGroupIds.TryGetValue(identity.ToLower(), out id))
                    groupId = id;
            }

            if (!groupId.HasValue)
                groupId = GetIdentityGroupId(identity);

            if (!groupId.HasValue)
                groupId = _defaultGroupId;

            if (!groupId.HasValue)
                return null;

            IdentityGroup identityGroup;
            lock(_groups)
                _groups.TryGetValue(groupId.Value, out identityGroup);
            return identityGroup;
        }

        public bool IdentityIsInRole(string identity, string roleCodeName)
        {
            var group = FindIdentityGroup(identity);
            if (group == null) return false;

            var internedName = string.Intern(roleCodeName.ToLower());
            return group.IdentityRoles.Any(r => ReferenceEquals(r.CodeName, internedName));
        }

        public bool IdentityHasPermission(string identity, string permissionCodeName, string resourceName)
        {
            var group = FindIdentityGroup(identity);
            if (group == null) return false;

            if (group.GroupId == _administratorsGroupId) return true;

            var internedName = string.Intern(permissionCodeName.ToLower());
            return group.IdentityPermissions.Any(p => ReferenceEquals(p.CodeName, internedName));
        }

        #endregion

        #region Stored procedure wrappers

        public IEnumerable<Group> GetGroups(Func<Group, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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

        public IEnumerable<Role> GetRoles(Func<Role, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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

        public IEnumerable<Permission> GetPermissions(Func<Permission, bool> filterFunction = null)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddGroup"))
                {
                    command.AddParameter("groupCodeName", group.CodeName);
                    command.AddParameter("groupDisplayName", group.DisplayName);
                    command.AddParameter("groupDescription", group.Description);
                    command.AddParameter("groupPermissionId", group.PermissionId);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Role NewRole(Role role)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_UpdateGroup"))
                {
                    command.AddParameter("groupId", group.Id);
                    command.AddParameter("groupCodeName", group.CodeName);
                    command.AddParameter("groupDisplayName", group.DisplayName);
                    command.AddParameter("groupDescription", group.Description);
                    command.AddParameter("groupPermissionId", group.PermissionId);
                    using (var results = context.ExecuteEnumerable<Group>(command))
                    {
                        return results.FirstOrDefault();
                    }
                }
            }
        }

        public Role UpdateRole(Role role)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_AddPermission"))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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

        public long? GetIdentityGroupId(string identity)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityGroupId"))
                {
                    command.AddParameter("identity", identity);
                    return context.ExecuteScalar<long?>(command);
                }
            }
        }

        public Group GetIdentityGroup(string identity)
        {
            var groupId = GetIdentityGroupId(identity);
            if (!groupId.HasValue) return null;

            using (var context = _contextFactory.Create(_repositoryName))
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

        public IEnumerable<Role> GetIdentityRoles(string identity)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityRoles"))
                {
                    command.AddParameter("identity", identity);
                    using (var results = context.ExecuteEnumerable<Role>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public IEnumerable<Permission> GetIdentityPermissions(string identity)
        {
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_GetIdentityPermissions"))
                {
                    command.AddParameter("identity", identity);
                    using (var results = context.ExecuteEnumerable<Permission>(command))
                    {
                        return results.ToList();
                    }
                }
            }
        }

        public Group ChangeIdentityGroup(string identity, long groupId)
        {
            try
            {
                using (var context = _contextFactory.Create(_repositoryName))
                {
                    using (var command = _commandFactory.CreateStoredProcedure("sp_ChangeIdentityGroup"))
                    {
                        command.AddParameter("identity", identity);
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
                    _identityGroupIds.Remove(identity.ToLower());
            }
        }

        public void AddRoleToGroup(long roleId, long groupId)
        {
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
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
            using (var context = _contextFactory.Create(_repositoryName))
            {
                using (var command = _commandFactory.CreateStoredProcedure("sp_DeleteRolePermission"))
                {
                    command.AddParameter("roleId", roleId);
                    command.AddParameter("permissionId", permissionId);
                    context.ExecuteNonQuery(command);
                }
            }
        }

        #endregion
    }
}
