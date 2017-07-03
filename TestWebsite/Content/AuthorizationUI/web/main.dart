import 'dart:html';

import 'MVVM/View.dart';
import 'ViewModels/AuthorizationViewModel.dart';
import 'Views/Pages/ManageAuthorizationView.dart';

Element _uiDiv;
AuthorizationViewModel _viewModel;
View _view;

main()
{ 
	_uiDiv = querySelector('#auth-ui');
	_viewModel = new AuthorizationViewModel();
	_view = new ManageAuthorizationView(_viewModel);
	_view.displayIn(_uiDiv);
}
