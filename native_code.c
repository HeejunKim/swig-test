/* File : native_code.c */

#include "native_code.h"


/*
 * default
 */

/* Compute factorial of n */
int fact(int n) {
  if (n <= 1)
    return 1;
  else
    return n*fact(n-1);
}

/* Compute n mod m */
int my_mod(int n, int m) {
  return(n % m);
}

/*
 * array
 */

/* copy the contents of the first array to the second */
void my_array_copy(int* sourceArray, int* targetArray, int nitems) {
  int i;
  for (i = 0; i < nitems; i++) {
    targetArray[i] = sourceArray[i];
  }
}

/* swap the contents of the two arrays */
void my_array_swap(int* array1, int* array2, int nitems) {
  int i, temp;
  for (i = 0; i < nitems; i++) {
    temp = array1[i];
    array1[i] = array2[i];
    array2[i] = temp;
  }
}
