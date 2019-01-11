#include <iostream>
#include <set>
#include <vector>
#include <algorithm>
#include <random>
#include <unistd.h>

using namespace std;

typedef unsigned short ushort;

typedef ushort Digit;

struct Cell
{
  Digit       digit;
  set<Cell *> neighbors;
  set<Digit>  allowed;

  Cell(void) : digit(0) 
  {
    for(int i=1; i<10; ++i) allowed.insert(i);
  }
};

Cell grid[9][9];

void add_digit(int row,int col);
void display_grid(void);

int main(int argc,char **argv)
{
  std::srand(getpid());

  for(int row=0; row<9; ++row)
    for(int col=0; col<9; ++col)
    {
      Cell &cell = grid[row][col];

      int boxRow = row/3;
      int boxCol = col/3;

      for(int i=0; i<9; ++i)
      {
        // add row/col neighbors
        if ( i != col ) { cell.neighbors.insert( &(grid[row][i]) ); }
        if ( i != row ) { cell.neighbors.insert( &(grid[i][col]) ); }

        // add box neighbors
        int rr = boxRow + i/3;
        int cc = boxCol + i%3;

        if( rr != row && cc != col ) { cell.neighbors.insert( &(grid[rr][cc]) ); }
      }
    }

  add_digit(0,0);
}

void add_digit(int row, int col)
{
  static std::random_device rd;
  static std::mt19937 g(rd());

  Cell &cell = grid[row][col];

  if(cell.allowed.empty())
  {
    return;
  }

  vector<Digit> toTry(cell.allowed.begin(), cell.allowed.end());

  shuffle(toTry.begin(),toTry.end(),g);


  for(vector<Digit>::iterator cand=toTry.begin(); cand!=toTry.end(); ++cand)
  {
    cell.digit = *cand;

    if(row==8 && col==8)
    {
      cout << "DONE" << endl;
      display_grid();
      exit(1);
    }

    for(set<Cell *>::iterator n=cell.neighbors.begin(); n!=cell.neighbors.end(); ++n)
    {
      (*n)->allowed.erase(*cand);
    }


    add_digit( (col==8 ? row+1 : row), (col==8 ? 0 : col+1) );


    cell.digit = 0;

    for(set<Cell *>::iterator n=cell.neighbors.begin(); n!=cell.neighbors.end(); ++n)
    {
      (*n)->allowed.insert(*cand);
    }
  }
}

void display_grid(void)
{
  cout << "+---+---+---+" << endl;
  for(int i=0; i<9; ++i)
  {
    cout << '|';
    for(int j=0; j<9; ++j)
    {
      Digit d = grid[i][j].digit;
      if( d > 0 ) cout << d;
      else cout << ' ';
      if(j%3==2) cout << '|';
    }
    cout << endl;
    if( i%3==2) cout << "+---+---+---+" << endl;
  }
}
