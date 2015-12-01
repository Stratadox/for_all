#define test_for_all_array
/**
 * test_for_all_array()
 * Called by the GmUnit test framework to initiate
 * a simple hello world assertion to test array support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'Concatenating each value in the array should yield the expected result';
test[1] = 'Hello world!';

var parts;
parts[0] = 'Hello';
parts[1] = ' ';
parts[2] = 'world';
parts[3] = '!';

repeat for_all(parts) {
    actual += this_one();
}

test[0] = actual;

return test;

#define test_for_all_list
/**
 * test_for_all_list()
 * Called by the GmUnit test framework to initiate
 * a simple hello world assertion to test ds_list support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'Concatenating each value in the ds_list should yield the expected result';
test[1] = 'Hello world!';

var parts = ds_list_create();
ds_list_add(parts, 'Hello');
ds_list_add(parts, ' ');
ds_list_add(parts, 'world');
ds_list_add(parts, '!');

repeat for_all(parts) {
    actual += this_one();
}

ds_list_destroy(parts);
test[0] = actual;

return test;

#define test_for_all_map
/**
 * test_for_all_map()
 * Called by the GmUnit test framework to initiate
 * a simple summing assertion to test ds_map support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = 0;

test[2] = 'Summing each value in the ds_map should yield the expected result';
test[1] = 115;

var items = ds_map_create();
ds_map_add(items, 'health potion', 10);
ds_map_add(items, 'mana potion', 5);
ds_map_add(items, 'gold', 100);

repeat for_all(items, ds_type_map) {
    actual += this_one();
}
ds_map_destroy(items);

test[0] = actual;

return test;

#define test_for_all_key_value
/**
 * test_for_all_key_value()
 * Called by the GmUnit test framework to initiate
 * a simple concatenation assertion to test key/value support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'Concatenating each key and value in the array should yield the expected result';
test[1] = '0?1a2b3c';

var parts;
parts[0] = '?';
parts[1] = 'a';
parts[2] = 'b';
parts[3] = 'c';

repeat for_all(parts) {
    actual += string(this_key()) + this_value();
}

test[0] = actual;

return test;

#define test_for_all_grid
/**
 * test_for_all_grid()
 * Called by the GmUnit test framework to initiate
 * a simple summing assertion to test ds_grid support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = 0;

test[2] = 'Summing each value in the ds_grid should yield the expected result';
test[1] = 36;

var cases = ds_grid_create(3, 3);
ds_grid_clear(cases, 4);

repeat for_all(cases, ds_type_grid) {
    actual += this_one();
}

ds_grid_destroy(cases);
test[0] = actual;

return test;

#define test_for_all_grid_column
/**
 * test_for_all_grid_column()
 * Called by the GmUnit test framework to initiate
 * a simple summing assertion to test ds_grid column support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = 0;

test[2] = 'Summing each value in the ds_grid column should yield the expected result';
test[1] = 16;

var cases = ds_grid_create(3, 4);
ds_grid_clear(cases, 4);

repeat for_all(cases, ds_type_grid_column, 1) {
    actual += this_one();
}

ds_grid_destroy(cases);
test[0] = actual;

return test;

#define test_for_all_grid_row
/**
 * test_for_all_grid_column()
 * Called by the GmUnit test framework to initiate
 * a simple summing assertion to test ds_grid row support
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = 0;

test[2] = 'Summing each value in the ds_grid row should yield the expected result';
test[1] = 12;

var cases = ds_grid_create(3, 4);
ds_grid_clear(cases, 4);

repeat for_all(cases, ds_type_grid_row, 1) {
    actual += this_one();
}

ds_grid_destroy(cases);
test[0] = actual;

return test;

#define test_for_all_grid_key_value
/**
 * test_for_all_grid_key_value()
 * Called by the GmUnit test framework to initiate
 * a test asserting grid keys yield the expected array
 * 
 * @return array; The expected value and actual result
 */ 

var test, expected_key, actual = 0;

test[2] = 'The key of a ds_grid loop should yield the expected (array) result';
expected_key[0] = 2;
expected_key[1] = 3;

test[1] = expected_key;

var cases = ds_grid_create(3, 4);
ds_grid_clear(cases, 4);
ds_grid_set(cases, 2, 3, 5)

repeat for_all(cases, ds_type_grid) {
    if (this_one() == 5) {
        actual = this_key(false);
    }
}

ds_grid_destroy(cases);
test[0] = actual;

return test;

#define test_for_all_is_first
/**
 * test_for_all_is_first()
 * Called by the GmUnit test framework to initiate
 * a test asserting that the this_is_first function works correctly
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'The this_is_first function should return true in the first iteration of a loop';
test[1] = 'first!';

var posts;
posts[0] = 'first!';
posts[1] = 'second!';
posts[2] = 'third!';

repeat for_all(posts) {
    if (this_is_first(true)) {
        actual = this_value();
    }
}

test[0] = actual;

return test;

#define test_for_all_is_last
/**
 * test_for_all_is_last()
 * Called by the GmUnit test framework to initiate
 * a test asserting that the this_is_last function works correctly
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'The this_is_last function should return true in the last iteration of a loop';
test[1] = 'third!';

var posts;
posts[0] = 'first!';
posts[1] = 'second!';
posts[2] = 'third!';

repeat for_all(posts) {
    if (this_is_last(true)) {
        actual = this_value();
    }
}

test[0] = actual;

return test;

#define test_for_all_stop
/**
 * test_for_all_stop()
 * Called by the GmUnit test framework to initiate
 * a test asserting that the stop_here function works correctly
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = 0;

test[2] = 'The stop_here function should clear the current loop (and the current loop only)';
test[1] = 3;

var lists;
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
            ++actual;
        } else {
            stop_here();
            break;
        }
    }
}

test[0] = actual;

return test;

#define test_for_all_custom
/**
 * test_for_all_custom()
 * Called by the GmUnit test framework to initiate
 * a test asserting that the ds_type_custom feature works correctly
 * 
 * @return array; The expected value and actual result
 */ 

var test, actual = '';

test[2] = 'The for_all loop should be extensible through ds_type_custom';
test[1] = 'eeeeee';

repeat for_all('The for_all loop should be extensible through ds_type_custom', ds_type_custom, 'testscript_for_all_e') {
    actual += this_one();
}

test[0] = actual;

return test;

#define testscript_for_all_e
/**
 * testscript_for_all_e(input)
 * Test script that enables for_all to loop over all occurences of "e" in the input string
 *
 * @param string input; The string whose e's to loop over
 *
 * @return real;        The amount of loops
 */

var size    = string_count('e', argument0);
var values  = global.for_all_values;
var keys    = global.for_all_keys;
var i       = size;

repeat (size) {
    ds_stack_push(values, 'e');
    ds_stack_push(keys, i--);
}

return size;

