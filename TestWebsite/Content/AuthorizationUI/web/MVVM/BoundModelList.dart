part of mvvm;

// Abstract base class for components that bind to a list of view models and models.
// * Subscribes to events from add/remove actions when bound to a list
// * Refreshes the list UI when items are added or removed from the list
// * Unsubscribes from add/remove events when unbound 
// * When items in the list are selected, identifies the element and calls the selection method

abstract class BoundModelList<TM extends Model, TVM extends ViewModel, TV extends View> extends BoundViewModelListBase<TVM, TV>
{
  BoundModelList(
    ViewFactory viewFactory, 
    Element container,
    {
      selectionMethod : null
    })
    : super(viewFactory, container, selectionMethod: selectionMethod);
  
  ModelList<TM, TVM> _binding;
  ModelList<TM, TVM> get binding => _binding;

  void set binding(ModelList<TM, TVM> value)
  {
    super._unsubscribeFromEvents();

    _binding = value;

    if (value != null)
    {
      refresh();
      _addSubscription = value.onAdd.listen(_onAdd);      
      _deleteSubscription = value.onDelete.listen(_onDelete);
      _listChangedSubscription = value.onListChanged.listen(_onListChanged);
    }
  }  

  List<TVM> getViewModels()
  {
    if (_binding == null) return null;
    return binding.viewModels;
  }
}