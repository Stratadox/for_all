#define for_all_init
/** 
 * for_all_init()
 * Initialises the for_all mechanism
 */

global.for_all_values           = ds_stack_create();
global.for_all_keys             = ds_stack_create();
global.for_all_sizes            = ds_stack_create();

global.for_all_current_key      = undefined;
global.for_all_current_value    = undefined;

global.for_all_is_first         = undefined;
global.for_all_is_last          = undefined;

enum treat_as {
    list        = ds_type_list,
    map         = ds_type_map,
    grid        = ds_type_grid,
    grid_row    = -1,
    grid_column = -2,
    custom      = -3,
}

#define for_all
/** 
 * for_all(input, [treat_as], [index])
 * Call to initiate a for_all loop over an array or other data structure.
 *
 * @param   mixed input;                The array or data structure id or string to loop over
 * @param   real treat_as [optional];   The type of data structure to loop over
 *                                      - In case of treat_as.grid_column, a third argument `column_id` is required
 *                                      - In case of treat_as.grid_row, a third argument `row_id` is required
 *                                      - In case of treat_as.custom, a third argument `script` is required
 * @param   real index [optional];      The index of the row or column to loop over, or the id or name of the script to execute
 *
 * @return  real;                       The amount of iterations
 */

var input   = argument[0];
var values  = global.for_all_values;
var keys    = global.for_all_keys;
var size    = 0;
var i;

if (argument_count > 1 && argument[1] == treat_as.custom) {
    var script = argument[2];
    if (is_string(script)) {
        script = asset_get_index(script);
    }
    size = script_execute(script, input);
} else if (is_array(input)) {
    size = array_length_1d(input);
    i = size;
    repeat (size) {
        i--;
        for_all_push(i, input[i]);
    }
} else if (is_string(input)) {
    size = string_length(input);
    i = size;
    repeat (size) {
        for_all_push(i, string_char_at(input, i));
        i--;
    }
} else if (is_real(input)) {
    var type = treat_as.list;
    if (argument_count > 1) {
        type = argument[1];
    }
    switch (type) {
        case treat_as.map:
            size = ds_map_size(input);
            i = ds_map_find_last(input);
            repeat (size) {
                for_all_push(i, ds_map_find_value(input, i));
                i = ds_map_find_previous(input, i);
            }
        break;
        case treat_as.list:
            size = ds_list_size(input);
            i = size;
            repeat (size) {
                i--;
                for_all_push(i, ds_list_find_value(input, i));
            }
        break;
        case treat_as.grid:
            var col, w = ds_grid_width(input);
            var row, h = ds_grid_height(input);
            var pos;
            for (row = h - 1; row >= 0; --row) {
                for (col = w - 1; col >= 0; --col) {
                    pos[0] = col;
                    pos[1] = row;
                    for_all_push(pos, ds_grid_get(input, col, row));
                    pos = false; // unlink the array to prevent overwriting the stack
                }
            }
            size = w * h;
        break;
        case treat_as.grid_column:
            var column = argument[2];
            size = ds_grid_height(input);
            i = size;
            repeat (size) {
                i--;
                for_all_push(i, ds_grid_get(input, column, i));
            }
        break;
        case treat_as.grid_row:
            var row = argument[2];
            size = ds_grid_width(input);
            i = size;
            repeat (size) {
                i--;
                for_all_push(i, ds_grid_get(input, i, row));
            }
        break;
    }
}

if (size) {
    ds_stack_push(global.for_all_sizes, size);
    
    global.for_all_is_first = 2;
    global.for_all_is_last  = (size == 1);
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

global.for_all_is_first         = undefined;
global.for_all_is_last          = undefined;

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

if (global.for_all_is_first) {
    global.for_all_is_first--;
}
global.for_all_is_last = (!keys_left);

#define for_all_push
/**
 * for_all_push(key, value)
 * Used internally or by an extension script to add an
 * entry to the for_all stacks
 *
 * @param mixed key;    The key or index to push
 * @param mixed value;  The value to go along with it
 */

ds_stack_push(global.for_all_keys, argument0);
ds_stack_push(global.for_all_values, argument1);

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

#define this_key
/**
 * this_key([pop=true])
 * Use to retrieve the current key and progress to the next iteration
 * Must be called once in each iteration of the loop
 * 
 * Beware! Use either this function or this_one() - not both!
 * 
 * @param   bool pop [optional, default=true];  Set to true if the loop still needs to iterate
 *
 * @return  mixed;                              The next key in the loop
 */

if (argument_count == 0 || argument[0]){
    for_all_pop();
}
return global.for_all_current_key;

#define this_value
/**
 * this_value([pop=false])
 * Use to retrieve the current value
 * 
 * Beware! Do not confuse with this_one()
 * 
 * @param   bool pop [optional, default=false]; Set to true if the loop still needs to iterate
 *
 * @return  mixed;                              The next value in the loop
 */

if (argument_count > 0 && argument[0]) {
    for_all_pop();
}
return global.for_all_current_value;

#define this_is_first
/**
 * this_is_first([pop=false])
 * Use to check if this is the first iteration of the current loop
 * 
 * @param   bool pop [optional, default=false]; Set to true if the loop still needs to iterate
 *
 * @return  boolean;                            True if first, false otherwise
 */

if (argument_count > 0 && argument[0]) {
    for_all_pop();
}
return !!global.for_all_is_first;

#define this_is_last
/**
 * this_is_last([pop=false])
 * Use to check if this is the last iteration of the current loop
 * 
 * @param   bool pop [optional, default=false]; Set to true if the loop still needs to iterate
 *
 * @return  boolean;                            True if last, false otherwise
 */

if (argument_count > 0 && argument[0]) {
    for_all_pop();
}
return !!global.for_all_is_last;

