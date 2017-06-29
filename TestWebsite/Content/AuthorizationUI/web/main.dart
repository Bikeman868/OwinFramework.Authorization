import 'dart:html';

main()
{ 
	InputElement version = querySelector('#version');
	Element div = querySelector('#auth-ui');

	div.innerHtml = r'<h1>User Authorization</h1>'
		+ '<p>Version ' + version.value + ' of the authorization user interface</p>';
}
