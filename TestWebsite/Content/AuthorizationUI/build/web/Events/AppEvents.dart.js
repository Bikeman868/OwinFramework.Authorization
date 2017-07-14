(function(){var supportsDirectProtoAccess=function(){var z=function(){}
z.prototype={p:{}}
var y=new z()
if(!(y.__proto__&&y.__proto__.p===z.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var x=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(x))return true}}catch(w){}return false}()
function map(a){a=Object.create(null)
a.x=0
delete a.x
return a}var A=map()
var B=map()
var C=map()
var D=map()
var E=map()
var F=map()
var G=map()
var H=map()
var J=map()
var K=map()
var L=map()
var M=map()
var N=map()
var O=map()
var P=map()
var Q=map()
var R=map()
var S=map()
var T=map()
var U=map()
var V=map()
var W=map()
var X=map()
var Y=map()
var Z=map()
function I(){}init()
function setupProgram(a,b){"use strict"
function generateAccessor(a9,b0,b1){var g=a9.split("-")
var f=g[0]
var e=f.length
var d=f.charCodeAt(e-1)
var c
if(g.length>1)c=true
else c=false
d=d>=60&&d<=64?d-59:d>=123&&d<=126?d-117:d>=37&&d<=43?d-27:0
if(d){var a0=d&3
var a1=d>>2
var a2=f=f.substring(0,e-1)
var a3=f.indexOf(":")
if(a3>0){a2=f.substring(0,a3)
f=f.substring(a3+1)}if(a0){var a4=a0&2?"r":""
var a5=a0&1?"this":"r"
var a6="return "+a5+"."+f
var a7=b1+".prototype.g"+a2+"="
var a8="function("+a4+"){"+a6+"}"
if(c)b0.push(a7+"$reflectable("+a8+");\n")
else b0.push(a7+a8+";\n")}if(a1){var a4=a1&2?"r,v":"v"
var a5=a1&1?"this":"r"
var a6=a5+"."+f+"=v"
var a7=b1+".prototype.s"+a2+"="
var a8="function("+a4+"){"+a6+"}"
if(c)b0.push(a7+"$reflectable("+a8+");\n")
else b0.push(a7+a8+";\n")}}return f}function defineClass(a1,a2){var g=[]
var f="function "+a1+"("
var e=""
for(var d=0;d<a2.length;d++){if(d!=0)f+=", "
var c=generateAccessor(a2[d],g,a1)
var a0="p_"+c
f+=a0
e+="this."+c+" = "+a0+";\n"}if(supportsDirectProtoAccess)e+="this."+"$deferredAction"+"();"
f+=") {\n"+e+"}\n"
f+=a1+".builtin$cls=\""+a1+"\";\n"
f+="$desc=$collectedClasses."+a1+"[1];\n"
f+=a1+".prototype = $desc;\n"
if(typeof defineClass.name!="string")f+=a1+".name=\""+a1+"\";\n"
f+=g.join("")
return f}var z=supportsDirectProtoAccess?function(c,d){var g=c.prototype
g.__proto__=d.prototype
g.constructor=c
g["$is"+c.name]=c
return convertToFastObject(g)}:function(){function tmp(){}return function(a0,a1){tmp.prototype=a1.prototype
var g=new tmp()
convertToSlowObject(g)
var f=a0.prototype
var e=Object.keys(f)
for(var d=0;d<e.length;d++){var c=e[d]
g[c]=f[c]}g["$is"+a0.name]=a0
g.constructor=a0
a0.prototype=g
return g}}()
function finishClasses(a4){var g=init.allClasses
a4.combinedConstructorFunction+="return [\n"+a4.constructorsList.join(",\n  ")+"\n]"
var f=new Function("$collectedClasses",a4.combinedConstructorFunction)(a4.collected)
a4.combinedConstructorFunction=null
for(var e=0;e<f.length;e++){var d=f[e]
var c=d.name
var a0=a4.collected[c]
var a1=a0[0]
a0=a0[1]
g[c]=d
a1[c]=d}f=null
var a2=init.finishedClasses
function finishClass(a9){if(a2[a9])return
a2[a9]=true
var a5=a4.pending[a9]
if(!a5||typeof a5!="string"){var a6=g[a9]
var a7=a6.prototype
a7.constructor=a6
a7.$isa=a6
a7.$deferredAction=function(){}
return}finishClass(a5)
var a8=g[a5]
if(!a8)a8=existingIsolateProperties[a5]
var a6=g[a9]
var a7=z(a6,a8)
if(a7.$isd)a7.$deferredAction()}var a3=Object.keys(a4.pending)
for(var e=0;e<a3.length;e++)finishClass(a3[e])}function finishAddStubsHelper(){var g=this
while(!g.hasOwnProperty("$deferredAction"))g=g.__proto__
delete g.$deferredAction
var f=Object.keys(g)
for(var e=0;e<f.length;e++){var d=f[e]
var c=d.charCodeAt(0)
var a0
if(d!=="^"&&d!=="$reflectable"&&c!==43&&c!==42&&(a0=g[d])!=null&&a0.constructor===Array&&d!=="<>")addStubs(g,a0,d,false,[])}convertToFastObject(g)
g=g.__proto__
g.$deferredAction()}function processClassData(b1,b2,b3){b2=convertToSlowObject(b2)
var g
var f=Object.keys(b2)
var e=false
var d=supportsDirectProtoAccess&&b1!="a"
for(var c=0;c<f.length;c++){var a0=f[c]
var a1=a0.charCodeAt(0)
if(a0==="j"){processStatics(init.statics[b1]=b2.j,b3)
delete b2.j}else if(a1===43){w[g]=a0.substring(1)
var a2=b2[a0]
if(a2>0)b2[g].$reflectable=a2}else if(a1===42){b2[g].$D=b2[a0]
var a3=b2.$methodsWithOptionalArguments
if(!a3)b2.$methodsWithOptionalArguments=a3={}
a3[a0]=g}else{var a4=b2[a0]
if(a0!=="^"&&a4!=null&&a4.constructor===Array&&a0!=="<>")if(d)e=true
else addStubs(b2,a4,a0,false,[])
else g=a0}}if(e)b2.$deferredAction=finishAddStubsHelper
var a5=b2["^"],a6,a7,a8=a5
var a9=a8.split(";")
a8=a9[1]?a9[1].split(","):[]
a7=a9[0]
a6=a7.split(":")
if(a6.length==2){a7=a6[0]
var b0=a6[1]
if(b0)b2.$S=function(b4){return function(){return init.types[b4]}}(b0)}if(a7)b3.pending[b1]=a7
b3.combinedConstructorFunction+=defineClass(b1,a8)
b3.constructorsList.push(b1)
b3.collected[b1]=[m,b2]
i.push(b1)}function processStatics(a3,a4){var g=Object.keys(a3)
for(var f=0;f<g.length;f++){var e=g[f]
if(e==="^")continue
var d=a3[e]
var c=e.charCodeAt(0)
var a0
if(c===43){v[a0]=e.substring(1)
var a1=a3[e]
if(a1>0)a3[a0].$reflectable=a1
if(d&&d.length)init.typeInformation[a0]=d}else if(c===42){m[a0].$D=d
var a2=a3.$methodsWithOptionalArguments
if(!a2)a3.$methodsWithOptionalArguments=a2={}
a2[e]=a0}else if(typeof d==="function"){m[a0=e]=d
h.push(e)
init.globalFunctions[e]=d}else if(d.constructor===Array){}else{a0=e
processClassData(e,d,a4)}}}var y=0
if(!init.libraries)init.libraries=[]
if(!init.mangledNames)init.mangledNames=map()
if(!init.mangledGlobalNames)init.mangledGlobalNames=map()
if(!init.statics)init.statics=map()
if(!init.typeInformation)init.typeInformation=map()
if(!init.globalFunctions)init.globalFunctions=map()
var x=init.libraries
var w=init.mangledNames
var v=init.mangledGlobalNames
var u=Object.prototype.hasOwnProperty
var t=a.length
var s=map()
s.collected=map()
s.pending=map()
s.constructorsList=[]
s.combinedConstructorFunction="function $reflectable(fn){fn.$reflectable=1;return fn};\n"+"var $desc;\n"
for(var r=0;r<t;r++){var q=a[r]
var p=q[0]
var o=q[1]
var n=q[2]
var m=q[3]
var l=q[4]
var k=!!q[5]
var j=l&&l["^"]
if(j instanceof Array)j=j[0]
var i=[]
var h=[]
processStatics(l,s)
x.push([p,o,i,h,n,j,k,m])}finishClasses(s)}I.w=function(){}
var dart=[["","",,H,{"^":"",a3:{"^":"a;a"}}],["","",,J,{"^":"",
j:function(a){return void 0},
d:{"^":"a;",
h:function(a){return H.n(a)}},
H:{"^":"d;",
h:function(a){return String(a)},
$isU:1},
K:{"^":"d;",
h:function(a){return"null"}},
l:{"^":"d;",
h:function(a){return P.G(a,"[","]")},
gk:function(a){return a.length}},
a2:{"^":"l;"},
A:{"^":"a;a,b,c,d",
n:function(){var z,y,x
z=this.a
y=z.length
if(this.b!==y)throw H.b(H.a_(z))
x=this.c
if(x>=y){this.d=null
return!1}this.d=z[x]
this.c=x+1
return!0}},
t:{"^":"d;",
h:function(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
$ish:1},
J:{"^":"t;",$ish:1,$isY:1},
I:{"^":"t;",$ish:1},
m:{"^":"d;",
t:function(a,b){if(b>=a.length)throw H.b(H.v(a,b))
return a.charCodeAt(b)},
q:function(a,b,c){if(c==null)c=a.length
if(b>c)throw H.b(P.o(b,null,null))
if(c>a.length)throw H.b(P.o(c,null,null))
return a.substring(b,c)},
p:function(a,b){return this.q(a,b,null)},
h:function(a){return a},
gk:function(a){return a.length},
$isP:1}}],["","",,H,{"^":"",
c:function(a){var z
if(typeof a==="string")return a
if(typeof a==="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
z=J.k(a)
if(typeof z!=="string")throw H.b(H.T(a))
return z},
N:function(a){var z,y,x,w,v,u,t,s
z=J.j(a)
y=z.constructor
if(typeof y=="function"){x=y.name
w=typeof x==="string"?x:null}else w=null
if(w==null||z===C.b||!1){v=C.c(a)
if(v==="Object"){u=a.constructor
if(typeof u=="function"){t=String(u).match(/^\s*function\s*([\w$]*)\s*\(/)
s=t==null?null:t[1]
if(typeof s==="string"&&/^\w+$/.test(s))w=s}if(w==null)w=v}else w=v}w=w
if(w.length>1&&C.a.t(w,0)===36)w=C.a.p(w,1)
return function(b,c){return b.replace(/[^<,> ]+/g,function(d){return c[d]||d})}(w+H.x(H.X(a),0,null),init.mangledGlobalNames)},
n:function(a){return"Instance of '"+H.N(a)+"'"},
Z:function(a,b){if(a==null)J.q(a)
throw H.b(H.v(a,b))},
v:function(a,b){var z
if(typeof b!=="number"||Math.floor(b)!==b)return new P.i(!0,b,"index",null)
z=J.q(a)
if(b<0||b>=z)return P.F(b,a,"index",null,z)
return P.o(b,"index",null)},
T:function(a){return new P.i(!0,a,null,null)},
b:function(a){var z
if(a==null)a=new P.M()
z=new Error()
z.dartException=a
if("defineProperty" in Object){Object.defineProperty(z,"message",{get:H.z})
z.name=""}else z.toString=H.z
return z},
z:function(){return J.k(this.dartException)},
a_:function(a){throw H.b(new P.B(a))},
a0:function(a){throw H.b(new P.C(a))},
y:function(){throw H.b(new H.L("No top-level function named 'main'."))},
X:function(a){if(a==null)return
return a.$ti},
e:function(a,b){var z
if(a==null)return"dynamic"
if(typeof a==="object"&&a!==null&&a.constructor===Array)return a[0].builtin$cls+H.x(a,1,b)
if(typeof a=="function")return a.builtin$cls
if(typeof a==="number"&&Math.floor(a)===a)return H.c(a)
if(typeof a.func!="undefined"){z=a.typedef
if(z!=null)return H.e(z,b)
return H.R(a,b)}return"unknown-reified-type"},
R:function(a,b){var z,y,x,w,v,u,t,s,r,q,p
z=!!a.v?"void":H.e(a.ret,b)
if("args" in a){y=a.args
for(x=y.length,w="",v="",u=0;u<x;++u,v=", "){t=y[u]
w=w+v+H.e(t,b)}}else{w=""
v=""}if("opt" in a){s=a.opt
w+=v+"["
for(x=s.length,v="",u=0;u<x;++u,v=", "){t=s[u]
w=w+v+H.e(t,b)}w+="]"}if("named" in a){r=a.named
w+=v+"{"
for(x=H.V(r),q=x.length,v="",u=0;u<q;++u,v=", "){p=x[u]
w=w+v+H.e(r[p],b)+(" "+H.c(p))}w+="}"}return"("+w+") => "+z},
x:function(a,b,c){var z,y,x,w,v,u
if(a==null)return""
z=new P.u("")
for(y=b,x=!0,w=!0,v="";y<a.length;++y){if(x)x=!1
else z.i=v+", "
u=a[y]
if(u!=null)w=!1
v=z.i+=H.e(u,c)}return w?"":"<"+z.h(0)+">"},
L:{"^":"f;a",
h:function(a){return"NoSuchMethodError: "+this.a}}}],["","",,H,{"^":"",
V:function(a){var z=a?Object.keys(a):[]
z.fixed$length=Array
return z}}],["","",,P,{"^":"",
G:function(a,b,c){var z,y,x
if(P.S(a))return b+"..."+c
z=new P.u(b)
y=$.$get$p()
y.push(a)
try{x=z
x.i=P.Q(x.gi(),a,", ")}finally{if(0>=y.length)return H.Z(y,-1)
y.pop()}y=z
y.i=y.gi()+c
y=z.gi()
return y.charCodeAt(0)==0?y:y},
S:function(a){var z,y
for(z=0;y=$.$get$p(),z<y.length;++z)if(a===y[z])return!0
return!1}}],["","",,P,{"^":"",
r:function(a){if(typeof a==="number"||typeof a==="boolean"||null==a)return J.k(a)
if(typeof a==="string")return JSON.stringify(a)
return P.D(a)},
D:function(a){var z=J.j(a)
if(!!z.$isa1)return z.h(a)
return H.n(a)},
U:{"^":"a;",
h:function(a){return this?"true":"false"}},
"+bool":0,
a6:{"^":"h;"},
"+double":0,
f:{"^":"a;"},
M:{"^":"f;",
h:function(a){return"Throw of null."}},
i:{"^":"f;a,b,c,d",
gm:function(){return"Invalid argument"},
gl:function(){return""},
h:function(a){var z,y,x,w,v,u
z=this.c
y=z!=null?" ("+z+")":""
z=this.d
x=z==null?"":": "+z
w=this.gm()+y+x
v=this.gl()
u=P.r(this.b)
return w+v+": "+H.c(u)}},
O:{"^":"i;e,f,a,b,c,d",
gm:function(){return"RangeError"},
gl:function(){return""},
j:{
o:function(a,b,c){return new P.O(null,null,!0,a,b,"Value not in range")}}},
E:{"^":"i;e,k:f>,a,b,c,d",
gm:function(){return"RangeError"},
gl:function(){var z=this.b
if(typeof z!=="number")return z.u()
if(z<0)return": index must not be negative"
z=this.f
if(z===0)return": no indices are valid"
return": index should be less than "+z},
j:{
F:function(a,b,c,d,e){return new P.E(b,e,!0,a,c,"Index out of range")}}},
B:{"^":"f;a",
h:function(a){var z=this.a
if(z==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+H.c(P.r(z))+"."}},
C:{"^":"f;a",
h:function(a){var z=this.a
return z==null?"Reading static variable during its initialization":"Reading static variable '"+H.c(z)+"' during its initialization"}},
Y:{"^":"h;"},
"+int":0,
a4:{"^":"a;"},
"+List":0,
a5:{"^":"a;",
h:function(a){return"null"}},
"+Null":0,
h:{"^":"a;"},
"+num":0,
a:{"^":";",
h:function(a){return H.n(this)},
toString:function(){return this.h(this)}},
P:{"^":"a;"},
"+String":0,
u:{"^":"a;i<",
gk:function(a){return this.i.length},
h:function(a){var z=this.i
return z.charCodeAt(0)==0?z:z},
j:{
Q:function(a,b,c){var z=new J.A(b,b.length,0,null)
if(!z.n())return a
if(c.length===0){do a+=H.c(z.d)
while(z.n())}else{a+=H.c(z.d)
for(;z.n();)a=a+c+H.c(z.d)}return a}}}}]]
setupProgram(dart,0)
J.j=function(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.J.prototype
return J.I.prototype}if(typeof a=="string")return J.m.prototype
if(a==null)return J.K.prototype
if(typeof a=="boolean")return J.H.prototype
if(a.constructor==Array)return J.l.prototype
return a}
J.W=function(a){if(typeof a=="string")return J.m.prototype
if(a==null)return a
if(a.constructor==Array)return J.l.prototype
return a}
J.q=function(a){return J.W(a).gk(a)}
J.k=function(a){return J.j(a).h(a)}
var $=I.p
C.b=J.d.prototype
C.a=J.m.prototype
C.c=function getTagFallback(o) {  var s = Object.prototype.toString.call(o);  return s.substring(8, s.length - 1);}
$=null
init.isHunkLoaded=function(a){return!!$dart_deferred_initializers$[a]}
init.deferredInitialized=new Object(null)
init.isHunkInitialized=function(a){return init.deferredInitialized[a]}
init.initializeLoadedHunk=function(a){$dart_deferred_initializers$[a]($globals$,$)
init.deferredInitialized[a]=true}
init.deferredLibraryUris={}
init.deferredLibraryHashes={};(function(a){for(var z=0;z<a.length;){var y=a[z++]
var x=a[z++]
var w=a[z++]
I.$lazy(y,x,w)}})(["p","$get$p",function(){return[]}])
I=I.$finishIsolateConstructor(I)
$=new I()
init.metadata=[]
init.types=[]
function convertToFastObject(a){function MyClass(){}MyClass.prototype=a
new MyClass()
return a}function convertToSlowObject(a){a.__MAGIC_SLOW_PROPERTY=1
delete a.__MAGIC_SLOW_PROPERTY
return a}A=convertToFastObject(A)
B=convertToFastObject(B)
C=convertToFastObject(C)
D=convertToFastObject(D)
E=convertToFastObject(E)
F=convertToFastObject(F)
G=convertToFastObject(G)
H=convertToFastObject(H)
J=convertToFastObject(J)
K=convertToFastObject(K)
L=convertToFastObject(L)
M=convertToFastObject(M)
N=convertToFastObject(N)
O=convertToFastObject(O)
P=convertToFastObject(P)
Q=convertToFastObject(Q)
R=convertToFastObject(R)
S=convertToFastObject(S)
T=convertToFastObject(T)
U=convertToFastObject(U)
V=convertToFastObject(V)
W=convertToFastObject(W)
X=convertToFastObject(X)
Y=convertToFastObject(Y)
Z=convertToFastObject(Z)
function init(){I.p=Object.create(null)
init.allClasses=map()
init.getTypeFromName=function(a){return init.allClasses[a]}
init.interceptorsByTag=map()
init.leafTags=map()
init.finishedClasses=map()
I.$lazy=function(a,b,c,d,e){if(!init.lazies)init.lazies=Object.create(null)
init.lazies[a]=b
e=e||I.p
var z={}
var y={}
e[a]=z
e[b]=function(){var x=this[a]
if(x==y)H.a0(d||a)
try{if(x===z){this[a]=y
try{x=this[a]=c()}finally{if(x===z)this[a]=null}}return x}finally{this[b]=function(){return this[a]}}}}
I.$finishIsolateConstructor=function(a){var z=a.p
function Isolate(){var y=Object.keys(z)
for(var x=0;x<y.length;x++){var w=y[x]
this[w]=z[w]}var v=init.lazies
var u=v?Object.keys(v):[]
for(var x=0;x<u.length;x++)this[v[u[x]]]=null
function ForceEfficientMap(){}ForceEfficientMap.prototype=this
new ForceEfficientMap()
for(var x=0;x<u.length;x++){var t=v[u[x]]
this[t]=z[t]}}Isolate.prototype=a.prototype
Isolate.prototype.constructor=Isolate
Isolate.p=z
Isolate.w=a.w
return Isolate}}(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!='undefined'){a(document.currentScript)
return}var z=document.scripts
function onLoad(b){for(var x=0;x<z.length;++x)z[x].removeEventListener("load",onLoad,false)
a(b.target)}for(var y=0;y<z.length;++y)z[y].addEventListener("load",onLoad,false)})(function(a){init.currentScript=a
if(typeof dartMainRunner==="function")dartMainRunner(H.y,[])
else H.y([])})})()