import 'dart:async';

import '../MVVM/Events.dart';

import '../ViewModels/PermissionViewModel.dart';

class PermissionSelectedEvent
{
	PermissionViewModel permission;
	PermissionSelectedEvent(this.permission);
}

class ConfirmationMessageEvent
{
	String messsage;
	void() confirmAction;
	String confirmButton;
	String cancelButton;

	ConfirmationMessageEvent(String messsage, void() action, [String confirmButton = 'OK', String cancelButton = 'Cancel'])
	{
		this.message = message;
		this.confirmAction = action;
		this.confirmButton = confirmButton;
		this.cancelButton = cancelButton;
	}
}

class AppEvents
{
	static SubscriptionEvent<PermissionSelectedEvent>permissionSelected = new SubscriptionEvent<PermissionSelectedEvent>();
	static SubscriptionEvent<ConfirmationMessageEvent>confirm = new SubscriptionEvent<ConfirmationMessageEvent>();
}
