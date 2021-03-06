---
id: js_sqrt_using_arithmetic_operations
title: "JS sqrt function using arithmetic operators"
author: Aleksejs Ivanovs
date: 2017-11-17-T01
display_date: 17.11.2017
tags: [functional, math]
desc_no_tags: "Here is some nice function I've made that calculates a square root of a number: k=>(f=>f(f))(f=>x=>x==(y=(x+k/x)/2)?x:f(f)(y))(1)"
description: <p>Here is some nice function I've made that calculates a square root of a number:</p><pre>k=>(f=>f(f))(f=>x=>x==(y=(x+k/x)/2)?x:f(f)(y))(1)</pre><p>At first look this function is completely cryptic, however it produces exactly the same results for positive numbers as <span class="highlight">Math.sqrt()</span> function. Let's take a closer look and find out how does it work.</p><br>
---
<p>To make our job easier lets do some formatting:</p>
<pre>k =>
    (f => f(f))

    (f => x =>
      x == (y = (x + k/x)/2)
        ? x
        : f(f)(y)
    )(1)</pre>
<p>We've separated our code in two parts - the first part is an arrow function that we will dissect later, and the second part, where some arithmetic arrow function gets an argument 1. Let's check the second part because it looks simplier.</p>
<br />
<h2>Babylonian method<h2>
<br />
<p>Our function looks like this:</p>
<pre>(f => x =>
  x == (y = (x + k/x)/2)
    ? x
    : f(f)(y)
)(1)</pre>
<p>Function gets two arguments - <span class="highlight">f</span> and <span class="highlight">x</span>. We call <span class="highlight">f</span> at the 4th line and we can figure out that <span class="highlight">f</span> is a function. Let's ignore <span class="highlight">f</span> for now. We have a second argument <span class="highlight">x</span> which has initial value <span class="highlight">1</span> and we calculate <span class="highlight">y</span> which is equal to</p>
<span class="note">
  <span class="math">$y = \frac{x + k/x}{2}$</span>
</span>
<br>
<p>This is a <a href="https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method" target="_blank"><span class="highlight">Babylonian method</span></a> of computing square root. The idea is simple. Let's do some simple transformations:</p>
<span class="note">
  <span class="math">$y = \frac{x + k/x}{2} = \frac{x^2 + k}{2x}$</span>
</span>
<p>Let's think about what <span class="highlight">(x<sup>2</sup> + k)/2</span> is. It's an average between our <span class="highlight">x squared</span> and our number <span class="highlight">k</span>. So, we can think about <span class="highlight">y</span> as approximation of square root of <span class="highlight">k</span>.</p>
<p>Imagine that we are trying to guess the value of square root of <span class="highlight">k</span> and our guess is that <span class="highlight">x</span>. If we guessed right and the number <span class="highlight">x</span> is equal to the square root of <span class="highlight">k</span> then <span class="highlight">x<sup>2</sup></span> will be equal to <span class="highlight">k</span>. In other words, <span class="highlight">y</span> will be equal to <span class="highlight">x</span> and to square root of <span class="highlight">k</span>. But when we guessed wrong and <span class="highlight">x</span> is not equal to the square root of <span class="highlight">k</span> then <span class="highlight">y</span> will be something between <span class="highlight">x</span> and square root of <span class="highlight">k</span>. The logic is that the average between our guess and the real square root is closer to the real square root than our guess.Then we can use <span class="highlight">y</span> as the new guess, or the new value of <span class="highlight">x</span> to get a better approximation. We just need to repeat calculations until <span class="highlight">y</span> is equal to <span class="highlight">x</span>. You can define <span class="highlight">Babylonian method</span> as:</p>
<br>
<span class="note">
  <span class="math">$x_0 = 1, x_{n+1} = \frac{x_n + k/x_n}{2}$</span>
</span>
<br>
<p>It's easier to undersand Babylonian with an example. Let's find <span class="highlight">sqrt(12)</span>. At first iteration <span class="highlight">x</span> is <span class="highlight">1</span> and <span class="highlight">y</span> will be equal to <span class="highlight">(1 + 12/1)/2 = 6.5</span>. At second iteration we have <span class="highlight">x</span> equal to <span class="highlight">6.5</span> and <span class="highlight">y = (6.5 + 12/6.5)/2</span> which is about <span class="highlight">4.17</span>. Next iteration, <span class="highlight">x</span> is equal to <span class="highlight">4.17</span>, <span class="highlight">y</span> will be <span class="highlight">(4.17 + 12/4.17)/2</span> or about <span class="highlight">3.523</span>. At next iteration y will be equal to about <span class="highlight">3.464</span> and we can see that it is not very far from our previous average which is <span class="highlight">3.523</span>.</p>
<p>We can see that our calculation slowly comes to the point where <span class="highlight">x</span> and <span class="highlight">y</span> are equal. We can continue if we need a better precision but we can easily figure out that if number <span class="highlight">k</span> is not perfect square then it's square root is irrational (there's a proof for that) and it will never converge. That's why we have to stop recursion at some moment. Help comes from the fact that numbers in JavaScript have finite precision and not really irrational. It means that our algorithm will eventually generate equal <span class="highlight">x</span> and <span class="highlight">y</span>.</p>
<br />
<h2>Fixed point combinator<h2>
<br />
<p>Now that we know how Babylonian method works we need to understand how exactly we repeat calculations. The next part of our job is more complicated. We need to decipher that strange line <span class="code">f => f(f)</span>. As we know, functions can be passed as the argument to other functions. Here we pass some function <span class="highlight">f</span> as an argument and we call that function <span class="highlight">f</span>, and provide <span class="highlight">f</span> itself as an argument to itself. Sounds weird? Let's find out why we want to do something so strange.</p>
<br>
<p>Take a look on the line <span class="code">f => x =></span>. If you are familiar with the concept of <a href="https://en.wikipedia.org/wiki/Currying" target="_blank"><span class="highlight">currying</span></a> then you can figure out what happens here. Currying is a process of transforming the function with several arguments into several functions with one argument each. Let's take a look on the example.</p>
<pre>const foo = (x => y => x + y)

const bar = foo(2)

foo(2)(3) == bar(3) // Both expressions return 5</pre>
<p>At first line we created a function that uses currying. It's clearer what happens there if you rewrite it as</p>
<pre>const foo = (x => (y => x + y))</pre>
<p>Function <span class="highlight">bar</span> will partially apply <span class="highlight">2</span> to function <span class="highlight">foo</span>. It will return a new function that already has one argument applied (partially applied function). At third line you can see how you can use both these functions. Some languages like <span class="highlight">Haskell</span> support currying by design. <span class="highlight">JavaScript</span> supports currying via chain of arrow functions or with help of <span class="highlight">.bind()</span> method.</p>
<br>
<p>Now what happens if we use currying in combination with our <span class="code">f => f(f)</span> function? Our Babylonian function's arguments look like <span class="code">f => x =></span>. So, the whole function <span class="code">f=>x=>x==(y=(x+k/x)/2)?x:f(f)(y)</span> is partially applied to itself as the argument <span class="highlight">f</span> and then it calls itself using itself as the first argument. Then it only has to receive an argument <span class="highlight">x</span>.</p>
<p>So, to summarize, we use function <span class="code">f => f(f)</span> to partially apply a Babylonian function to itself. In other words, our Babylonian function gets itself as the first argument and then it calls itself passing itself as the first argument. Yes, this is recursion, and we made it without specifying a name for a function.</p>
<br>
<p>Usually, when you need a recursion you name it and then call it using that name. Here's a simple recursive factorial function:</p>
<pre>const fact = (n =>
  n == 0
    ? 1
    : n * fact(n - 1)
)</pre>
<p>Our <span class="code">f => f(f)</span> allows us to use recursion by partially applying a function to itself. This construction is called <a href="https://en.wikipedia.org/wiki/Fixed-point_combinator" target="_blank"><span class="highlight">fixed-point combinator</span></a> and can be used to create recursion in lambda functions. Let's rewrite our factorial example using fixed-point combinator.</p>
<pre>(f => f(f))

(f => n =>
  n == 0
    ? 1
    : n * f(f)(n - 1)
)</pre>
<p>Now we know what <span class="code">f => f(f)</span> does and we can go back to our <span class="highlight">sqrt</span> function. We now understand how Babylonian function recursively calls itself and calculates <span class="highlight">y<sub>n+1</sub></span> until <span class="highlight">y<sub>n+1</sub></span> is equal to <span class="highlight">y<sub>n</sub></span>.</p>
<br>
<p>Fixed-point combinator is useful in languages that allow to create lambda functions. It's also necessary in systems like lambda calculus because there's no other way to create recursion there. It provides formal definition for recursions in functional languages and it allows to create a recursion in languages that don't support it by design.</p>
<br>
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
