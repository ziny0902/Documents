#include <stdio.h>

class a {
  public:
    void call(void);
};
void a::call(void)
{
  printf("hellow world\n");
}

int main()
{
  a instant;
  instant.call();
}
