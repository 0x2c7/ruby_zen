VALUE rb_cArray;
VALUE rb_cString;
VALUE rb_cInteger;
VALUE rb_cFloat;
VALUE rb_cHash;
VALUE rb_cNumeric;
VALUE rb_cTrueClass;
VALUE rb_cFalseClass;
VALUE rb_mEnumerable;

/*
 *  call-seq:
 *      ary.initialize
 *      ary.initialize -> ary
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_initialize(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.inspect => ""
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_inspect(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.length -> str
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_length(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.try_convert => "[a, b, c]"
 *      ary.try_convert => bool or {}
 *      ary.try_convert => bool
 *      ary.try_convert => [] or {}
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_try_convert(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.freeze = hsh
 *      freeze(a = {}, b = 5) = 0, 1, -1
 *      freeze(a = {}, b = 5)
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_freeze(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.dup -> hsh or Hash or hash
 *      dup(a = {}, b = 5) -> bignum
 *      dup(a = {}, b = 5)
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_dup(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      ary.is_nil? -> str
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_is_nil(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *        to_a 
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_to_a(VALUE ary)
{
    return rb_obj_freeze(ary);
}

VALUE
rb_ary_to_f(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      abort
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_abort(VALUE ary)
{
    return rb_obj_freeze(ary);
}

/*
 *  call-seq:
 *      freeze(s)
 *      freeze { block }
 *
 *  Lorem ipsum
 *
 */

VALUE
rb_ary_useless_call_seq(VALUE ary)
{
    return rb_obj_freeze(ary);
}

VALUE
rb_no_call_seq(VALUE ary)
{
    return rb_obj_freeze(ary);
}

VALUE
rb_ary_exit(VALUE ary)
{
    return rb_obj_freeze(ary);
}

void
Init_Array(void)
{
#undef rb_intern
#define rb_intern(str) rb_intern_const(str)

    rb_cString = rb_define_class("String", rb_cObject);
    rb_cInteger = rb_define_class("Integer", rb_cInteger);
    rb_cFloat = rb_define_class("Float", rb_cFloat);
    rb_cHash = rb_define_class("Hash", rb_cObject);
    rb_cNumeric = rb_define_class("Numeric", rb_cObject);
    rb_cTrueClass = rb_define_class("TrueClass", rb_cObject);
    rb_cFalseClass = rb_define_class("FalseClass", rb_cObject);
    rb_mEnumerable = rb_define_module("Enumerable");
    rb_cArray  = rb_define_class("Array", rb_cObject);
    rb_include_module(rb_cArray, rb_mEnumerable);

    rb_define_alloc_func(rb_cArray, empty_ary_alloc);
    rb_define_singleton_method(rb_cArray, "dup", rb_ary_dup, 0);
    rb_define_singleton_method(rb_cArray, "try_convert", rb_ary_try_convert, 1);
    rb_define_method(rb_cArray, "freeze", rb_ary_freeze, 0);
    rb_define_method(rb_cArray, "initialize", rb_ary_initialize, 0);
    rb_define_method(rb_cArray, "length", rb_ary_length, 0);
    rb_define_method(rb_cArray, "is_nil?", rb_ary_is_nil, 0)
    rb_define_method(rb_cArray, "to_a", rb_ary_to_a, 0)
    rb_define_method(rb_cArray, "to_f", rb_ary_to_f, 0)
    rb_define_singleton_method(rb_cArray, "abort", rb_ary_abort, 0)
    rb_define_method(rb_cArray, "exit", rb_ary_exit, 0)

    rb_define_method(rb_cArray, "no_call_seq", rb_no_call_seq, 0);
    rb_define_method(rb_cArray, "useless_call_seq", rb_ary_useless_call_seq, 0);


    rb_define_method(rb_cArray,  "inspect", rb_ary_inspect, 0);
    rb_define_alias(rb_cArray,  "to_s", "inspect");
}
