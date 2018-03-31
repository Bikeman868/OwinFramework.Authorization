import '../MVVM/Mvvm.dart';
import '../ViewModels/GroupViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../ViewModels/PermissionViewModel.dart';
import '../ViewModels/IdentityViewModel.dart';

class PermissionSelectedEvent
{
	PermissionViewModel permission;
	PermissionSelectedEvent(this.permission);
}

class RoleSelectedEvent
{
	RoleViewModel role;
	RoleSelectedEvent(this.role);
}

class GroupSelectedEvent
{
	GroupViewModel group;
	GroupSelectedEvent(this.group);
}

class IdentitySelectedEvent
{
	IdentityViewModel identity;
	IdentitySelectedEvent(this.identity);
}

class ConfirmationMessageEvent
{
	String messsage;
	Function confirmAction;
	String confirmButton;
	String cancelButton;

	ConfirmationMessageEvent(this.messsage, this.confirmAction, [this.confirmButton = 'OK', this.cancelButton = 'Cancel'])
	{
	}
}

class AppEvents
{
	static SubscriptionEvent<GroupSelectedEvent>groupSelected = new SubscriptionEvent<GroupSelectedEvent>();
	static SubscriptionEvent<RoleSelectedEvent>roleSelected = new SubscriptionEvent<RoleSelectedEvent>();
	static SubscriptionEvent<IdentitySelectedEvent>identitySelected = new SubscriptionEvent<IdentitySelectedEvent>();
	static SubscriptionEvent<PermissionSelectedEvent>permissionSelected = new SubscriptionEvent<PermissionSelectedEvent>();
	static SubscriptionEvent<ConfirmationMessageEvent>confirm = new SubscriptionEvent<ConfirmationMessageEvent>();
}
