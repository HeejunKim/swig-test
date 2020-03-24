
/* File : native_code.h */

#ifdef __cplusplus
extern "C" {
#endif

// default
int fact(int n);
int my_mod(int n, int m);

// array
void my_array_copy(int* source_array, int* target_array, int nitems);
void my_array_swap(int* array1, int* array2, int nitems);

#ifdef __cplusplus
}
#endif
