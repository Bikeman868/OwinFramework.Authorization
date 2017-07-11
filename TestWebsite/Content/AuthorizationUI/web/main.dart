import 'dart:html';

import 'MVVM/View.dart';
import 'ViewModels/AuthorizationViewModel.dart';
import 'Views/Pages/DesktopView.dart';
import 'Views/Pages/MobileView.dart';

Element _uiDiv;
AuthorizationViewModel _viewModel;
View _view;

main()
{ 
	_uiDiv = querySelector('#auth-ui');
	_viewModel = new AuthorizationViewModel();

	if (_uiDiv.clientWidth > 500)
		_view = new DesktopView(_viewModel);
	else
		_view = new MobileView(_viewModel);

	_view.displayIn(_uiDiv);
}
