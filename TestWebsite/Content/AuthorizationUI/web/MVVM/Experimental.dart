import 'dart:html';
import 'dart:async';

void main() {
  var element = querySelector('#dart');
}

/*==============  Framework code  ==============*/

typedef T ValueGetter<T>();
typedef void ValueSetter<T>(T v);

class SubscriptionEvent<E>
{
	StreamController<E> _controller = new StreamController.broadcast();
  
	raise(E e)
	{
		_controller.add(e);
	}

	StreamSubscription<E> listen(void handler(E e)) 
	{
		return _controller.stream.listen(handler);
	}
}

class Binding<T> {
  T value;

  ValueGetter<T> getValue;
  ValueSetter<T> setValue;

  SubscriptionEvent<T> onChange;

  Binding({this.value: null, this.getValue: null, this.setValue: null}) {
    onChange = new SubscriptionEvent<T>();
    if (getValue == null) getValue = () => value;
    if (setValue == null)
      setValue = (v) {
        value = v;
        changed();
      };
  }

  changed() {
    onChange.raise(getValue());
  }
}

class ListBinding<T> {
  List<T> list;
  
  ValueGetter<List<T>> getList;
  ValueSetter<List<T>> setList;
  ValueSetter<T> add;
  ValueSetter<T> remove;

  SubscriptionEvent<List<T>> onChange;

  ListBinding(
      {this.list: null,
      this.getList: null,
      this.setList: null,
      this.add: null,
      this.remove: null}) {
    onChange = new SubscriptionEvent<List<T>>();
    
    if (getList == null) getList = () => list;

    if (setList == null)
      setList = (l) {
        list = l;
        changed();
      };

    if (add == null)
      add = (v) {
        if (list == null) list = new List<T>();
        list.add(v);
        changed();
      };

    if (remove == null)
      remove = (v) {
        if (list != null) {
          list.remove(remove);
          changed();
        }
      };
  }

  changed() {
    onChange.raise(getList());
  }
}

class Persist {
  final String name;

  const Persist(this.name);
}

class ViewModel {
  final String name;

  const ViewModel(this.name);
}

class View {
  final String name;
  final String template;
  final String templateUrl;

  const View(this.name, {this.template: null, this.templateUrl: null});
}

/*==============  Application code  ==============*/

class UserModel {
  @Persist('displayName')
  String displayName;
}

class UserViewModel {
  UserModel _user;

  Binding<String> name;

  UserViewModel(this._user) {
    name = new Binding<String>(
        getValue: () => _user.displayName,
        setValue: (v) {
          _user.displayName = v;
          name.changed();
        });
  }
}

class UserListViewModel {
  ListBinding<UserViewModel> users;

  UserListViewModel(List<UserViewModel> userList) {
    users = new ListBinding<UserViewModel>(list: userList);
  }
}

@View('userName', template: '<span class="user-name">{{user.name}}</span>')
class UserNameView {
  @ViewModel('user')
  UserViewModel user;
}

@View('userNameList',
    template: '''
    <ul>
    	<repeat for="userList.users">
      	<li class="user">
        	<view name="userName"/>
      	</li>
      </repeat>
    <ul>
    ''')
class UserNameListView {
  @ViewModel('userList')
  UserListViewModel userList;
}
