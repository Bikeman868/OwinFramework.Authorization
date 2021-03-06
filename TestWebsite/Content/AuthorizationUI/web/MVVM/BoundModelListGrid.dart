﻿part of mvvm;

// Creates tiles in a grid with one view inside each tile

class BoundModelListGrid<TM extends Model, TVM extends ViewModel, TV extends View> extends BoundModelList
{
  BoundModelListGrid(
		ViewFactory<TVM, TV> viewFactory,
		Element gridContainer, 
		{
			ViewModelMethod<TVM> selectionMethod : null,
			this.showDeleted : false
		}) 
		: super(viewFactory, gridContainer, selectionMethod: selectionMethod)
    {
    }
 
  void initializeContainer(Element container)
  {
    container.classes.add('bound-grid');
  }

	bool showDeleted;
  
  void refresh()
  {
    if (container == null) return;

		var builder = new HtmlBuilder();
    if (binding != null && binding.viewModels != null)
    {
      for (var index = 0; index < binding.viewModels.length; index++)
      {
				var viewModel = binding.viewModels[index];
				if (showDeleted || viewModel.getState() != ChangeState.deleted)
				{
					var tile = builder.addContainer(classNames:['tile', 'bound-tile']);
					if (selectionMethod != null) 
					{
						tile.attributes['index'] = index.toString();
						tile.classes.add('selection-item');
						tile.onClick.listen(itemClicked);
					};

					viewFactory(viewModel).addTo(tile);
				}
      }
    }
    builder.displayIn(container);
  }
}
