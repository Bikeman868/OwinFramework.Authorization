import 'dart:async';

import '../MVVM/Events.dart';

import '../ViewModels/GroupViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../ViewModels/PermissionViewModel.dart';

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

class ConfirmationMessageEvent
{
	String messsage;
	void() confirmAction;
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
	static SubscriptionEvent<PermissionSelectedEvent>permissionSelected = new SubscriptionEvent<PermissionSelectedEvent>();
	static SubscriptionEvent<ConfirmationMessageEvent>confirm = new SubscriptionEvent<ConfirmationMessageEvent>();
}
