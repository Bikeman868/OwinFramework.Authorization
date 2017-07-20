import 'dart:html';

import 'MVVM/HtmlBuilder.dart';
import 'MVVM/View.dart';
import 'Server.dart';

import 'ViewModels/AuthorizationViewModel.dart';
import 'Views/Pages/DesktopView.dart';
import 'Views/Pages/MobileView.dart';

Element _uiDiv;
AuthorizationViewModel _viewModel;
View _view;

main()
{ 
	Server.Initialize();
	HtmlBuilder.Initialize();

	_uiDiv = querySelector('#auth-ui');
	_viewModel = new AuthorizationViewModel();

	if (_uiDiv.clientWidth > 760)
		_view = new DesktopView(_viewModel);
	else
		_view = new MobileView(_viewModel);

	_view.displayIn(_uiDiv);
}
