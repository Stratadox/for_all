#define for_all_init
/** 
 * for_all_init()
 * Initialises the for_all mechanism
 */

global.for_all_values   = ds_stack_create();
global.for_all_keys     = ds_stack_create();
global.for_all_sizes    = ds_stack_create();

global.for_all_current_key      = undefined;
global.for_all_current_value    = undefined;

#define for_all
/** 
 * for_all(input, [ds_type], [index])
 * Call to initiate a for_all loop over an array or other data structure.
 *
 * @param   mixed input;                The array or data structure id or string to loop over
 * @param   real ds_type [optional];    The type of data structure to loop over
 * @param   real index [optional];      The index of the row or column to loop over
 * @return  real;                       The amount of iterations
 */

var input   = argument[0];
var values  = global.for_all_values;
var keys    = global.for_all_keys;
var size    = 0;
var i;

if (is_array(input)) {
    size = array_length_1d(input);
    i = size;
    repeat (size) {
        ds_stack_push(values, input[--i]);
        ds_stack_push(keys, i);
    }
} else if(is_string(input)) {
    size = string_length(input);
    i = size;
    repeat (size) {
        ds_stack_push(values, string_char_at(input, i));
        ds_stack_push(keys, i--);
    }
} else if (is_real(input)) {
    var type = ds_type_list;
    if (argument_count > 1) {
        type = argument[1];
    }
    switch (type) {
        case ds_type_map:
            if (!ds_exists(input, ds_type_map)) {
                return 0;
            }
            size = ds_map_size(input);
            i = ds_map_find_last(input);
            repeat (size) {
                ds_stack_push(values, ds_map_find_value(input, i));
                ds_stack_push(keys, i);
                i = ds_map_find_previous(input, i);
            }
        break;
        case ds_type_list:
            if (!ds_exists(input, ds_type_list)) {
                return 0;
            }
            size = ds_list_size(input);
            i = size;
            repeat (size) {
                ds_stack_push(values, ds_list_find_value(input, --i));
                ds_stack_push(keys, i);
            }
        break;
        case ds_type_grid:
            if (!ds_exists(input, ds_type_grid)) {
                return 0;
            }
            var _x, w = ds_grid_width(input);
            var _y, h = ds_grid_height(input);
            var pos;
            for (_y = h - 1; _y >= 0; --_y) {
                for (_x = w - 1; _x >= 0; --_x) {
                    ds_stack_push(values, ds_grid_get(input, _x, _y));
                    pos[0] = _x;
                    pos[1] = _y;
                    ds_stack_push(keys, pos);
                    pos = false; // destroy the array to prevent overwriting the stack
                }
            }
            size = w * h;
        break;
        case ds_type_grid_column:
            if (!ds_exists(input, ds_type_grid)) {
                return 0;
            }
            var column = argument[2];
            size = ds_grid_height(input);
            i = size;
            repeat (size) {
                ds_stack_push(values, ds_grid_get(input, column, --i));
                ds_stack_push(keys, i);
            }
        break;
        case ds_type_grid_row:
            if (!ds_exists(input, ds_type_grid)) {
                return 0;
            }
            var row = argument[2];
            size = ds_grid_width(input);
            i = size;
            repeat (size) {
                ds_stack_push(values, ds_grid_get(input, --i, row));
                ds_stack_push(keys, i);
            }
        break;
    }
}

if (size) {
    ds_stack_push(global.for_all_sizes, size);
}
return size;

#define for_all_clear
/**
 * for_all_clear()
 * Use to reset the internal loop management stacks
 * Must be called right before exit;
 */

ds_stack_clear(global.for_all_keys);
ds_stack_clear(global.for_all_values);
ds_stack_clear(global.for_all_sizes);

global.for_all_current_key      = undefined;
global.for_all_current_value    = undefined;

#define for_all_pop
/**
 * for_all_pop()
 * Called internally to load the current item and progress to the next iteration
 * and manage the size counters.
 */

var keys_left;
do {
    keys_left  = ds_stack_pop(global.for_all_sizes) - 1;
    if (keys_left >= 0) {
        ds_stack_push(global.for_all_sizes, keys_left);
    }
} until (keys_left >= 0);

global.for_all_current_key      = ds_stack_pop(global.for_all_keys);
global.for_all_current_value    = ds_stack_pop(global.for_all_values);

#define stop_here
/**
 * stop_here()
 * Use to cancel the current loop
 * Must be called right before break;
 */

var keys_left  = ds_stack_pop(global.for_all_sizes);

repeat (keys_left) {
    ds_stack_pop(global.for_all_keys);
    ds_stack_pop(global.for_all_values);
}

#define this_key
/**
 * this_key([first=true])
 * Use to retrieve the current key and progress to the next iteration
 * Must be called once in each iteration of the loop
 * 
 * Beware! Use either this function or this_one() - not both!
 * 
 * @param   bool first [optional, default=true];    Whether or not this is called before this_value
 * @return  mixed;                                  The next key in the loop
 */

var first = true;
if (argument_count > 0) {
    first = argument[0];
}
if (first) {
    for_all_pop();
}
return global.for_all_current_key;

#define this_one
/**
 * this_one()
 * Use to retrieve the current value and progress to the next iteration
 * Must be called once in each iteration of the loop
 * 
 * Beware! Use either this function or this_key() and this_value() - not both!
 * 
 * @return  mixed;  The next value in the loop
 */

for_all_pop();
return global.for_all_current_value;

#define this_value
/**
 * this_value([first=false])
 * Use to retrieve the current value
 * 
 * Beware! Do not confuse with this_one()
 * 
 * @param   bool first [optional, default=true];    Whether or not this is called before this_value
 * @return  mixed;                                  The next value in the loop
 */

if (argument_count > 0) {
    if (argument[0]) {
        for_all_pop();
    }
}
return global.for_all_current_value;

