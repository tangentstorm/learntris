use std::io;

fn readln() -> String {
  let mut s = String::new();
  io::stdin().read_line(&mut s)
    .expect("failed to read input line.");
  s }

struct Game {
  score: u32, count: u32, matrix : Vec<Vec<char>>
}

fn vec2d<T:Copy>(h:usize, w:usize, fill:T) -> Vec<Vec<T>> {
  (0..h).map(|_|{ (0..w).map(|_|fill).collect()}).collect() }

impl Game {
  fn new() -> Game {
    Game { score:0, count:0, matrix: vec2d(22,10,'.') }}

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
}

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
        '?' => match chars.next() {
                 Some('s') => println!("{}", g.score),
                 Some('n') => println!("{}", g.count),
                 _ => panic!("expected ('s'|'n') after '?'") }
        _ => {} }}}}
