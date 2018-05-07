library mvvm;

import 'dart:html';
import 'dart:async';

part 'Types.dart';
part 'Events.dart';
part 'HtmlBuilder.dart';

part 'Model.dart';
part 'View.dart';
part 'ViewModel.dart';

part 'ModelList.dart';
part 'ViewModelList.dart';
part 'PropertyBinding.dart';
part 'ViewModelBinding.dart';
part 'StringBinding.dart';
part 'IntBinding.dart';

part 'BoundViewModelListBase.dart';
part 'BoundViewModelList.dart';
part 'BoundModelList.dart';

part 'BoundModelListRepeater.dart';
part 'BoundModelListGrid.dart';
part 'BoundModelListList.dart';

part 'BoundViewModelListRepeater.dart';

part 'BoundElement.dart';
part 'BoundFormatter.dart';
part 'BoundIframe.dart';
part 'BoundImage.dart';
part 'BoundLabel.dart';
part 'BoundSelect.dart';
part 'BoundTextArea.dart';
part 'BoundTextInput.dart';
part 'BoundView.dart';

enum ChangeState
{
	unmodified,
	added,
	deleted,
	modified
}

enum SaveResult
{
	unmodified,
	saved,
	failed,
	notsaved
}
