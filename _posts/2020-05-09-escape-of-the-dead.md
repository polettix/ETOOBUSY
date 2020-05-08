---
title: Escape of the dead
type: post
tags: [ print-and-play, board game, blog ]
comment: true
date: 2020-05-09 01:34:31 +0200
published: true
---

**TL;DR**

> [Escape of the dead][] (sic) is a little *print-and-play* game that I
> never played but I find amusing.

Here's a way to play it online with some effort on your side:

0. read the [rules][]!
1. select the kind of action for the four slots and press the `Roll`
button
2. execute the action on the relevant radio buttons

Have fun!

<div id="app" style="border: 1px solid gray">
<table>

 <tr>
  <th style="width: 5em; vertical-align: top; text-align: right">Killed</th>
  <td>
   <input type="radio" name="kills" checked />0
   <input type="radio" name="kills" />1
   <input type="radio" name="kills" />2
   <input type="radio" name="kills" />3
   <input type="radio" name="kills" />4
   <input type="radio" name="kills" />5
   <input type="radio" name="kills" />6
   <input type="radio" name="kills" />7
   <input type="radio" name="kills" />8
   <input type="radio" name="kills" />9
   <input type="radio" name="kills" />10<sup title="Empty lawn / No new zombies next turn / Car +10% / Barricade +3">?</sup>
  </td>
 </tr>

 <tr>
  <th style="width: 5em; vertical-align: top; text-align: right">Lawn</th>
  <td>
   <input type="radio" name="lawn" />0
   <input type="radio" name="lawn" checked />1
   <input type="radio" name="lawn" />2
   <input type="radio" name="lawn" />3
   <input type="radio" name="lawn" />4
   <input type="radio" name="lawn" />5
   <input type="radio" name="lawn" />6
  </td>
 </tr>

 <tr>
  <th style="width: 5em; vertical-align: top; text-align: right">Barricade</th>
  <td>
   <input type="radio" name="fence" />0
   <input type="radio" name="fence" />1
   <input type="radio" name="fence" />2
   <input type="radio" name="fence" />3
   <input type="radio" name="fence" />4
   <input type="radio" name="fence" />5
   <input type="radio" name="fence" />6
   <input type="radio" name="fence" />7
   <input type="radio" name="fence" />8
   <input type="radio" name="fence" />9
   <input type="radio" name="fence" checked />10
  </td>
 </tr>

 <tr>
  <th style="width: 5em; vertical-align: top; text-align: right">Car</th>
  <td>
   <table>
   <tr>
   <td>
   <input type="radio" name="car" checked />0%
   <input type="radio" name="car" />10%
   <input type="radio" name="car" />20%
   <input type="radio" name="car" />30%
   </td>
   <td>+1 zombie per turn</td>
   </tr>
   <tr>
   <td>
   <input type="radio" name="car" />40%
   <input type="radio" name="car" />50%
   <input type="radio" name="car" />60%
   </td>
   <td>+2 zombies per turn</td>
   </tr>
   <tr>
   <td>
   <input type="radio" name="car" />70%
   <input type="radio" name="car" />80%
   </td>
   <td>+3 zombies per turn</td>
   </tr>
   <tr>
   <td>
   <input type="radio" name="car" />90%
   </td>
   <td>+4 zombies per turn</td>
   </tr>
   <tr>
   <td>
   <input type="radio" name="car" />100%
   </td>
   <td>YES! You made it!</td>
   </tr>
   </table>
  </td>
 </tr>

</table>

{% raw %}
<table>
 <tr>
  <th>Action 1</th>
  <th>Action 2</th>
  <th>Action 3</th>
  <th>Action 4</th>
 </tr>
 <tr>
  <td>
   <input type="radio" name="die1" v-model="actions[0]" value="zombie">Shoot zombies<br />
   <input type="radio" name="die1" v-model="actions[0]" value="barricade">Fix barricade<br />
   <input type="radio" name="die1" v-model="actions[0]" value="car">Fix car
  </td>
  <td>
   <input type="radio" name="die2" v-model="actions[1]" value="zombie">Shoot zombies<br />
   <input type="radio" name="die2" v-model="actions[1]" value="barricade">Fix barricade<br />
   <input type="radio" name="die2" v-model="actions[1]" value="car">Fix car
  </td>
  <td>
   <input type="radio" name="die3" v-model="actions[2]" value="zombie">Shoot zombies<br />
   <input type="radio" name="die3" v-model="actions[2]" value="barricade">Fix barricade<br />
   <input type="radio" name="die3" v-model="actions[2]" value="car">Fix car
  </td>
  <td>
   <input type="radio" name="die4" v-model="actions[3]" value="zombie">Shoot zombies<br />
   <input type="radio" name="die4" v-model="actions[3]" value="barricade">Fix barricade<br />
   <input type="radio" name="die4" v-model="actions[3]" value="car">Fix car
  </td>
 </tr>
 <tr>
  <td><img v-bind:src="dice[0]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[1]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[2]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
  <td><img v-bind:src="dice[3]" alt="some die here" style="width: 100px; margin: 7px; box-sizing: border-box;"></td>
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
      dice: [
        '{{ '/assets/images/eotd/eotd.png' | prepend: site.baseurl }}',
        '{{ '/assets/images/eotd/eotd.png' | prepend: site.baseurl }}',
        '{{ '/assets/images/eotd/eotd.png' | prepend: site.baseurl }}',
        '{{ '/assets/images/eotd/eotd.png' | prepend: site.baseurl }}',
      ],
    },
    methods: {
      roll: function () {
        var url_for = {
            car: [
                '{{ '/assets/images/eotd/car-broken.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/car-broken.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/car-repaired.png' | prepend: site.baseurl }}',
            ],
            barricade: [
                '{{ '/assets/images/eotd/fence-broken.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/fence-repaired.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/fence-repaired.png' | prepend: site.baseurl }}',
            ],
            zombie: [
                '{{ '/assets/images/eotd/zombie-missed.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/zombie-hit.png' | prepend: site.baseurl }}',
                '{{ '/assets/images/eotd/zombie-hit.png' | prepend: site.baseurl }}',
            ],
        };
        this.dice = [0, 1, 2, 3].map(
            id => {
                var random_roll = Math.floor(Math.random() * 3);
                return url_for[this.actions[id]][random_roll];
            }
        );
      },
    }
  })
</script>

[Escape of the dead]: https://boardgamegeek.com/boardgame/87632/escape-dead-minigame
[rules]: https://boardgamegeek.com/filepage/62886/escape-dead-contest-entry-version-or-v102
