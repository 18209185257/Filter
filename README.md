## 第七章 函数表达式
匿名函数的name属性是空字符串
```
`var functionName = function(arg0, arg1, arg2) {
// 函数体
}
```
`javascript之理解参数按值传递
```
`function createFunctions() {
var result = new Array()
for (var i = 0; i \< 10; i++) {
result[i]() = function (num) {
return function () {
return num;
}
};
}
return result;
}
for (var a in createFunctions()) {
console.log(a)
}
/*  0
 1
 2
 3
 4
 5
 6
 7
 8
 9
 */这是为什么呢？为什么num就是i呢
````

