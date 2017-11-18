---
id: js_sqrt_using_arithmetic_operations
title: "JS sqrt function using arithmetic operators"
author: Aleksejs Ivanovs
date: 17.11.2017
tags: [functional, math]
description: <p>Here is some nice function I've made that calculates a square root of a number:</p><pre>k=>(f=>f(f))(f=>x=>x==(y=(x+k/x)/2)?x:f(f)(y))(1)</pre>
---

<p>At first look this function is completely cryptic, however it produces exactly the same results for positive numbers as <span class="highlight">Math.sqrt()</span> function. Let's take a closer look and find out how does it work.</p>
<br>
<p>To make our job easier lets do some formatting:</p>
<pre>k =>
(f => f(f))

(f => x =>
  x == (y = (x + k/x)/2)
    ? x
    : f(f)(y)
)(1)</pre>
<p>We split our code in two parts. Let's check the second part because it has only arithmetic operations and looks simple. Let's skip an argument <span class="highlight">f</span> for now. We have an argument <span class="highlight">x</span> which has initial value <span class="highlight">1</span> and we calculate <span class="highlight">y</span> which is equal to</p>
<br>
<span class="note">
  <span class="math">$y = \frac{x + k/x}{2}$</span>
</span>
<br>
<p>This is a <a href="https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method" target="_blank"><span class="highlight">Babylonian method</span></a> of computing square root. The idea is simple. If you transform <span class="highlight">x + k/x</span> to <span class="highlight">(x<sup>2</sup> + k)/x</span> then you can see that we calculate the average of <span class="highlight">x</span> squared and <span class="highlight">k</span>, all divided by <span class="highlight">x</span>. If that number (y) is equal to <span class="highlight">x</span> then we can know this is our answer. If it's not then we use <span class="highlight">y</span> as the next <span class="highlight">x</span>. You can define Babylonian method as:</p>
<br>
<span class="note">
  <span class="math">$x_0 = 1, x_{n+1} = \frac{x_n + k/x_n}{2}$</span>
</span>
<br>
<p>Example: let's find <span class="highlight">sqrt(12)</span>. At first iteration <span class="highlight">y</span> will be equal to <span class="highlight">(1 + 12/1)/2 = 6.5</span>. At second iteration we have <span class="highlight">x</span> equal to <span class="highlight">6.5</span> and <span class="highlight">y = (6.5 + 12/6.5)/2</span> which is about <span class="highlight">4.17</span>. Next iteration, <span class="highlight">x</span> is equal to <span class="highlight">4.17</span>, <span class="highlight">y</span> will be <span class="highlight">(4.17 + 12/4.17)/2</span> or about <span class="highlight">3.523</span>. At next iteration y will be equal to about <span class="highlight">3.464</span> and we can see that it is not very far from our previous average which is <span class="highlight">3.523</span>. We can figure out that our calculation slowly comes to the point where <span class="highlight">x</span> and <span class="highlight">y</span> are equal. We can continue if we need a better precision but we can easily figure out that if number <span class="highlight">k</span> is not perfect square then it's square root is irrational (there's a proof for that) and it will never converge. That's why we have to stop recursion at some moment. Help comes from the fact that numbers in JavaScript have finite precision and not really irrational. It means that our algorithm will eventually generate equal <span class="highlight">x</span> and <span class="highlight">y</span>.</p>
<br>
<p>The next part is more complicated. We need to decipher that strange line <span class="code">f => f(f)</span>. As we know, functions can be passed as the argument to other functions. We can figure out that it's what happens there. We pass a function as an argument then we call that function, and we also pass the same function as an argument to itself.</p>
<p>Take a look on the line <span class="code">f => x =></span>. If you are familiar with the concept of <a href="https://en.wikipedia.org/wiki/Currying" target="_blank"><span class="highlight">currying</span></a> then you can figure out what happens here. This line will create a function that returns another, partially applied function. Let's take a look on this example: <span class="code">const foo = (x => y => x + y)(2)</span>. This line will create another function that already has got 2 as an argument and it waits for one more argument. Once you pass it like foo(3) it will yield a final value 5. Some languages like Haskell support currying by design. JavaScript supports currying via chain of arrow functions or with help of .bind() method.</p>
<p>Now what happens if we use currying to pass a function to our <span class="code">f => f(f)</span>? It creates a new function that has already got our original function as the first argument. It then waits for an argument x. We can see that if x is not equal to y then we call f again passing f and y as arguments. Yes, this is recursion, and we made it without specifying a name for a function. Usually, when you need a recursion you specify a name for a function and then call it. Here's a simple recursive factorial function:</p>
<pre>const fact = (n =>
  n == 0
    ? 1
    : n * fact(n - 1)
)</pre>
<p>Our <span class="code">f => f(f)</span> allows us to use recursion without specifying name for a function. This construction is called <a href="https://en.wikipedia.org/wiki/Fixed-point_combinator" target="_blank"><span class="highlight">fixed-point combinator</span></a> and can be used to create recursion in lambda functions.</p>
<br>
<p>Let's rewrite our factorial example using fixed-point combinator:</p>
<pre>(f => f(f))

(f => n =>
  n == 0
    ? 1
    : n * f(f)(n - 1)
)</pre>
<p>Now we know what <span class="code">f => f(f)</span> does and we can go back to our sqrt function. We can see now that we recursively calculate the average until new average is equal to old average.</p>
<p>Fixed-point combinator is useful in languages that allow to create lambda functions. It's also necessary in systems like lambda calculus because there's no other way to create recursion there. It provides formal definition for recursions in functional languages and it allows to create a recursion in languages that don't support it by design.</p>
<p>Here are some definitions of fix in Haskell:</p>
<pre>-- recursive
fix f = f(fix f)

-- using let
fix f = let x = f x in x

-- point-free
fix = id >>= (. fix)</pre>
<p>The second definition can be found in <span class="highlight">Data.Function</span> as well as in <span class="highlight">Control.Monad.Fix</span>.</p>
<br>
<p>P. S. You can add a condition to our sqrt function if you want to handle negative values and NaN's the same way how <span class="highlight">Math.sqrt</span> does it:</p>
<pre>k=>isNaN(k)||k<0?NaN:(f=>f(f))(f=>x=>x==(y=(x+k/x)/2)?x:f(f)(y))(1)</pre>
<br>
<br>
