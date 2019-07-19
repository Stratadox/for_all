# for_all
This library adds the `repeat for_all` construct.

The `repeat for_all(x)` syntax is an emulated language construct, enabling a [foreach-like](https://en.wikipedia.org/wiki/Foreach_loop) loop structure in gml.

In many languages, there exists a loop known as the foreach loop. It is used like this:

```
words[0] = 'hello';
words[1] = 'world';

foreach (words as word) {
    output(word);
}

// or

for (word in words) {
    output(word);
}

```

A foreach loop is a convenient way to write loops through arrays or other data structures. As wikipedia puts it:

"For each (or foreach) is a computer language idiom for traversing items in a collection. Foreach is usually used in place of a standard for statement. Unlike other for loop constructs, however, foreach loops usually maintain no explicit counter: they essentially say "do this to everything in this set", rather than "do this x times". This avoids potential off-by-one errors and makes code simpler to read."

By default, no such thing is available for gml.

You would have to do "the whole thing" by hand, like so:
```
words[0] = 'hello';
words[1] = 'world';
 
var length = array_length_1d(words);
 
for (var i = 0; i < length; ++i) {
    output(words[i]);
}
```
Or at shortest:
```
words[0] = 'world';
words[1] = 'hello';
 
for (var i = array_length_1d(words) - 1; i >= 0; --i) {
    output(words[i]);
}
```
How tedious! How ugly!

With this extension installed, an entire new syntax becomes available.
Looping over an array will become as intuitive as this:
 
```
words[0] = 'hello';
words[1] = 'world';

repeat for_all(words) {
    output(this_one());
}
```

If you need the index of the entry in the loop, you can use a combination of this_key() and this_value() instead of this_one():
```
menu_items[0] = "Play";
menu_items[1] = "Help";
menu_items[2] = "Quit";

repeat for_all(menu_items) {
    draw_text(x, y + 50 * this_key(), '[ ' + this_value() + ' ]');
}
```

As a bonus, you can even use this loop type to iterate over other data structures. The following is also possible:

```
words = ds_list_create();
ds_list_add(words, 'hello');
ds_list_add(words, 'world');

repeat for_all(words) {
    output(this_one());
}
```

Or even this:

```
items = ds_map_create();
ds_map_add(items, 'health potion', 10);
ds_map_add(items, 'mana potion', 5);
ds_map_add(items, 'gold', 100);

str = 'Items:#';
repeat for_all(items, ds_type_map) {
    str += '- ' + this_key() + ' (' + this_value() + ')#';
}
```

(Careful though, ds_maps are hashmaps, so they can be in the loop in any order)

To loop over ds_grids, you have three options:

- Loop through all cells of the grid (ds_type_grid, makes this_key() return an array)
- Loop through the cells in a row (ds_type_grid_row, requires a third argument for row id)
- Loop through the cells in a column (ds_type_grid_column, requires a third argument for column id)

It is possible to use nested loops:

```
maps[0] = ds_map_create();
maps[1] = ds_map_create();

ds_map_add(maps[0], 'name', 'Player 1');
ds_map_add(maps[0], 'score', 1);
ds_map_add(maps[1], 'name', 'Player 2');
ds_map_add(maps[1], 'score', 2);

repeat for_all(maps) {
    str = '';
    repeat for_all(this_one()) {
        str += this_key() + ': ' + string(this_value()) + '#';
    }
    output(str);
}
```

...or to break (nested) loops, albeit with the requirement of calling stop_here():

```
lists[0] = ds_list_create();
lists[1] = ds_list_create();

ds_list_add(lists[0], 'ok');
ds_list_add(lists[0], 'ok');
ds_list_add(lists[0], 'not ok');
ds_list_add(lists[0], 'ok');

ds_list_add(lists[1], 'ok');
ds_list_add(lists[1], 'not ok');
ds_list_add(lists[1], 'ok');

repeat for_all(lists) {
    repeat for_all(this_one()) {
        if (this_one() == 'ok') {
            output('great');
        } else {
            stop_here();
            break;
        }
    }
}
```

The example above would end up executing output('great') three times.



This system works by pushing the data structure in reverse order to a global stack structure.
It therefore acts as queue for the array internally, but as stack on a per-batch level.

The advantage of this structure is that it allows for nesting the loops.
Another could be that it is possible to alter the array that is being looped over, without compromising the loop execution.
A potential disadvantage is that each time a value is popped, the for_all system sees it as an iteration.

What does that mean?

- When using the for_all loop, you must call either this_one() or this_key() exactly once in each loop iteration.
- If you need both value and key, you should use this_key() and this_value() instead of using this_one()
- If you need both value and key, but value first, you must use this_value(true) and this_key(false)
- When using break;, you must first call stop_here() to prevent stack contamination.
- When using exit;, you must first call for_all_clear() to prevent stack contamination.
- When using continue;, you must first call this_one() if you had not done so already.

Other than that, no worries.

The following functions are available:

- for_all(input, [ds_type], [index]) - Call to initiate a for_all loop over an array or other data structure.
- for_all_pop() - Called internally to load the current item and progress to the next iteration
- for_all_clear() - Use to reset the internal loop management stacks
- stop_here() - Use to cancel the current loop
- this_one() - Use to retrieve the current value and progress to the next iteration
- this_key([pop=true]) - Use to retrieve the current key and progress to the next iteration
- this_value([pop=false]) - Use to retrieve the current value
- this_is_first([pop=false]) - Use to check if this is the first iteration of the loop
- this_is_last([pop=false]) - Use to check if this is the last iteration of the loop
