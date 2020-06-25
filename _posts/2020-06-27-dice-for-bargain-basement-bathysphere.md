---
title: 'Dice for Bargain Basement Bathysphere (of Beachside Bay)'
type: post
tags: [ vuejs, print and play, board game, blog ]
comment: true
date: 2020-06-27 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some help for playing an interesting Roll-and-Write Print-and-Play
> free game: [Bargain Basement Bathysphere (of Beachside Bay)][bbbbb].

Thanks to a [SUDS video][] I discovered this game, which involves
rolling a few dice and *using* them along. 
Why not put [Vue][] at work once again and implement some support here in the
blog (see [Vue this blog][])? Let's do it!

Mark the dice with the checkbox as you use them, the checkboxes will be
reset when you roll the dice again. Of course... **you know** how many
dice you are allowed to use!

<div id="app" style="border: 1px solid gray">

{% raw %}
<table>
 <tr>
  <th style="text-align: center">1 <input type="checkbox" name="die1" value="die1" v-model="checked"></th>
  <th style="text-align: center">2 <input type="checkbox" name="die1" value="die2" v-model="checked"></th>
  <th style="text-align: center">3 <input type="checkbox" name="die1" value="die3" v-model="checked"></th>
  <th style="text-align: center">4 <input type="checkbox" name="die1" value="die4" v-model="checked"></th>
  <th style="text-align: center">5 <input type="checkbox" name="die1" value="die5" v-model="checked"></th>
 </tr>
 <tr>
  <td><img v-bind:src="dice[0]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[1]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[2]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[3]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[4]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
 </tr>
 <tr></tr>
 <tr>
  <td></td>
  <td><img v-bind:src="dice[5]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[6]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[7]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td></td>
 </tr>
 <tr>
  <th style="text-align: center"></th>
  <th style="text-align: center">6 <input type="checkbox" name="die1" value="die6" v-model="checked"></th>
  <th style="text-align: center">7 <input type="checkbox" name="die1" value="die7" v-model="checked"></th>
  <th style="text-align: center">8 <input type="checkbox" name="die1" value="die8" v-model="checked"></th>
  <th style="text-align: center"></th>
 </tr>
</table>
<button v-on:click="roll()" style="width: 100%; margin: auto; text-align: center; padding: 0.5em">Roll!</button>
{% endraw %}
</div>

<script src="{{ '/assets/js/vue.js'
    | prepend: site.baseurl
    | prepend: site.url }}">
</script>

<script>
  var app = new Vue({
    el: '#app',
    data: {
      actions: ['zombie', 'barricade', 'car', 'car'],
      checked: [],
      dice: [
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
        '{{ '/assets/images/d6/0.svg' | prepend: site.baseurl }}',
      ],
    },
    methods: {
      roll: function () {
        var url_for = {
            d6w: [
                '{{ '/assets/images/d6/1.svg' | prepend: site.baseurl }}',
                '{{ '/assets/images/d6/2.svg' | prepend: site.baseurl }}',
                '{{ '/assets/images/d6/3.svg' | prepend: site.baseurl }}',
                '{{ '/assets/images/d6/4.svg' | prepend: site.baseurl }}',
                '{{ '/assets/images/d6/5.svg' | prepend: site.baseurl }}',
                '{{ '/assets/images/d6/6.svg' | prepend: site.baseurl }}',
            ]
        };
        this.dice = [0, 1, 2, 3, 4, 5, 6, 7].map(
            id => {
                var random_roll = Math.floor(Math.random() * 6);
                return url_for['d6w'][random_roll];
            }
        );
        this.checked = [];
      },
    },
    mounted: function () { this.roll(); },
  })
</script>

Note: I'm just at the beginning and so far it seems that 5 dice are more
tha enough, but in the beginning there is an indication that up to 8
might be necessary... so there you go with 8.

[SUDS video]: https://www.youtube.com/watch?v=sNghPlwbYe8
[bbbbb]: https://boardgamegeek.com/boardgame/255360/bargain-basement-bathysphere/files
[Vue this blog]: {{ '/2020/05/08/vue-this-blog' | prepend: site.baseurl }}
[Vue]: https://cdn.jsdelivr.net/npm/vue/dist/vue.js
[ordeal]: https://ordeal.introm.it/
