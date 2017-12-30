/// rustris: a learntris implementation in rust

use std::io;

fn readln() -> String {
  let mut s = String::new();
  io::stdin().read_line(&mut s)
    .expect("failed to read input line.");
  s }

fn vec2d<T:Copy>(h:usize, w:usize, fill:T) -> Vec<Vec<T>> {
  (0..h).map(|_|{ (0..w).map(|_|fill).collect()}).collect() }


// -- 2-dimenstonal arrays -------------------------------------

struct Matrix<T> { h: usize, w:usize, data:Vec<T> }
type Tetramino = Matrix<char>;

impl Matrix<char> {
  fn new(h:usize, w:usize, s:&str) -> Self {
    assert_eq!(s.len(), h*w, "s.len() should match h*w");
    Tetramino{ h:h, w:w, data:s.chars().collect() }}

  fn print(&self) {
    for y in 0..self.h {
      for x in 0..self.w { print!("{} ", self.data[y*self.w + x]) }
      println!("") }}

  // rotate clockwise
  fn cw(&self) -> Self {
    let mut v = vec!();
    for y in 0..self.h { for x in 0..self.w { v.push(self.data[ self.w * (self.h-(x+1)) + y ]) }}
    Self{ h:self.w, w:self.h, data:v }}

}

// -- Game object ---------------------------------------------

struct Game { score: u32, count: u32, matrix : Vec<Vec<char>>, active:Tetramino }

impl Game {
  fn new() -> Game {
    Game { score:0, count:0, matrix: vec2d(22,10,'.'), active:Tetramino::new(1,1,"."), }}

  fn clear(&mut self) {
    self.matrix = vec2d(22,10,'.') }

  fn print_matrix(&self) {
    for y in 0..22 {
      for x in 0..10 { print!("{} ", self.matrix[y][x])}
      println!("")}}

  fn get_matrix(&mut self) {
    for y in 0..22 {
      let mut x = 0;
      for c in readln().chars() {
        if c==' ' || c=='\n' {}
        else { self.matrix[y][x]=c; x+=1 }}}}

  /// step = clear out completed lines
  fn step(&mut self) {
    let mut cleared = 0;
    self.matrix = self.matrix.iter().map(|row| {
      let num_blanks = row.iter().fold(0, |a,c| if *c=='.' {a+1} else {a});
      if num_blanks == 0 { cleared+=1; vec!['.'; 10 as usize] }
      else { row.clone() }
    }).collect();
    self.count += cleared; self.score += cleared*100;
  }
}

// -- command interpreter (main) ------------------------------

fn main() {
  let mut g = Game::new();
  loop {
    let s = readln(); let mut chars = s.chars();
    while let Some(c) = chars.next() {
      match c {
        'q' => return,
        'p' => g.print_matrix(),
        'g' => g.get_matrix(),
        'c' => g.clear(),
        's' => g.step(),
        'I' => g.active = Tetramino::new(4,4,"....cccc........"),
        'O' => g.active = Tetramino::new(2,2,"yyyy"),
        'Z' => g.active = Tetramino::new(3,3,"rr..rr..."),
        'S' => g.active = Tetramino::new(3,3,".gggg...."),
        'J' => g.active = Tetramino::new(3,3,"b..bbb..."),
        'L' => g.active = Tetramino::new(3,3,"..oooo..."),
        'T' => g.active = Tetramino::new(3,3,".m.mmm..."),
        ')' => g.active = g.active.cw(),
        't' => g.active.print(),
        ';' => println!(""),
        '?' => match chars.next() {
                 Some('s') => println!("{}", g.score),
                 Some('n') => println!("{}", g.count),
                 _ => panic!("expected ('s'|'n') after '?'") }
        _ => {} }}}}
