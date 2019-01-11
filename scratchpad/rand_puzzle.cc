#include <iostream>

typedef int Grid[9][9];

void shuffle(Grid &);

int main(int arg,char **argv)
{
  std::srand(std::time(nullptr));
  
  int raw[] = {
    1,2,3,4,5,6,7,8,9,
    4,5,6,7,8,9,1,2,3,
    7,8,9,1,2,3,4,5,6,
    2,3,1,5,6,4,8,9,7,
    5,6,4,8,9,7,2,3,1,
    8,9,7,2,3,1,5,6,4,
    3,1,2,6,4,5,9,7,8,
    6,4,5,9,7,8,3,1,2,
    9,7,8,3,1,2,6,4,5
  };

  Grid grid;
  for(int i=0; i<81; ++i)
  {
    grid[i/9][i%9] = raw[i];
  }

  for(int i=0;i<10000;++i)
  {
    shuffle(grid);
  }

  for(int i=0; i<9; ++i)
  {
    for(int j=0; j<9; ++j)
    {
      std::cout << ' ' << grid[i][j];
    }
    std::cout << std::endl;
  }

  return 0;
}

void shuffle(Grid &grid)
{
  int a = rand() % 3;
  int b = rand() % 2;
  if( (a==0) || (a==b) ) ++b;

  int d = 3 * (rand() % 3);

  a += d;
  b += d;

  if(rand() % 2) // swap rows
  {
    for(int i=0; i<9; ++i)
    {
      int t = grid[a][i];
      grid[a][i] = grid[b][i];
      grid[b][i] = t;
    }
  }
  else // swap cols
  {
    for(int i=0; i<9; ++i)
    {
      int t = grid[i][a];
      grid[i][a] = grid[i][b];
      grid[i][b] = t;
    }
  }
}
