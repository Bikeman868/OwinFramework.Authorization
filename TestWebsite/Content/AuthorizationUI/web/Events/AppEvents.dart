import 'dart:async';

import '../MVVM/Events.dart';

import '../ViewModels/PermissionViewModel.dart';

class PermissionSelectedEvent
{
	PermissionViewModel permission;
	PermissionSelectedEvent(this.permission);
}

class AppEvents
{
	static SubscriptionEvent<PermissionSelectedEvent>permissionSelected = new SubscriptionEvent<PermissionSelectedEvent>();
}
