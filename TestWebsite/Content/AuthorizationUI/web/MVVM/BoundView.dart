part of mvvm;

// Base class for classes that provide binding of a view to view model binding
// * Derrived classes must provide methods to subscribe to changes from the
//  view, and to update the view with changes from the view model

abstract class BoundView<TVM extends ViewModel, T, TV extends View>
{
	StreamSubscription<TVM> _bindingSubscription;
	ViewModelBinding<TVM, T> _binding;
	ViewModelBinding<TVM, T> get binding => _binding;

	void set binding(ViewModelBinding<TVM, T> value)
	{
		if (_bindingSubscription != null)
		{
			_bindingSubscription.cancel();
			_bindingSubscription = null;
		}
		_binding = value;
		if (value != null)
		{
			onBindingChange(value.getViewModel());
			_bindingSubscription = value.onChange.listen(onBindingChange);
		}
	}

	StreamSubscription<TVM> _viewSubscription;
	TV _view;
	TV get view => _view;

	void set view(TV value)
	{
		if (_viewSubscription != null)
		{
			_viewSubscription.cancel();
			_viewSubscription = null;
		}
		_view = value;
		if (value != null)
		{
			_viewSubscription = subscribeToView(value);
		}
		if (_binding != null)
			onBindingChange(_binding.getViewModel());
	}

	void dispose()
	{
		binding = null;
		view = null;
	}
  
	void onBindingChange(TVM viewModel);
	StreamSubscription<TVM> subscribeToView(TV view);
}
