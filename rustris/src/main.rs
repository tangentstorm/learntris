/// rustris: a learntris implementation in rust

use std::io;

fn readln() -> String {
  let mut s = String::new();
  io::stdin().read_line(&mut s).expect("failed to read input line.");
  s }


// -- 2-dimenstonal arrays -------------------------------------

struct Sprite { h: usize, w:usize, data:Vec<char> }

impl Sprite {

  fn new(h:usize, w:usize, s:&str) -> Self {
    assert_eq!(s.len(), h*w, "s.len() should match h*w");
    Self{ h:h, w:w, data:s.chars().collect() }}

  fn new_fill(h:usize, w:usize, fill:char) -> Self {
    Self{h:h, w:w, data:(0..h*w).map(|_|fill).collect() }}

  fn print(&self) {
    for y in 0..self.h {
      for x in 0..self.w { print!("{} ", self.data[y*self.w + x]) }
      println!("") }}

  fn set(&mut self, y:usize, x:usize, v:char) {
    self.data[y*self.w + x] = v; }

  fn get(&self, y:usize, x:usize) -> char {
    self.data[y*self.w + x] }

  // rotate clockwise
  fn cw(&self) -> Self {
    let mut v = vec!();
    for y in 0..self.h { for x in 0..self.w { v.push(self.data[ self.w * (self.h-(x+1)) + y ]) }}
    Self{ h:self.w, w:self.h, data:v }}

  fn hw(&self) -> (usize, usize) { (self.h, self.w) }

  fn to_uppercase(&self) -> Self {
    let mut up = vec!();
    for c in &self.data { up.extend(c.to_uppercase()) }
    Sprite{ h:self.h, w:self.w, data:up }}

  /// returns true if the cell is out of bounds or already filled
  fn collide_yx(&self, y:i32, x:i32) -> bool {
    if y < 0 || y >= (self.h as i32) { true }
    else if x < 0 || x >= (self.w as i32) { true }
    else { self.get(y as usize, x as usize) != '.' }}

  fn collide(&self, other:&Self, y:i32, x:i32) -> bool {
    for yy in 0..self.h { for xx in 0..self.w {
      if (self.get(yy, xx) != '.') && other.collide_yx(y+(yy as i32), x+(xx as i32)) { return true } }}
    false }

  fn onto(&self, other:&Self, y:usize, x:usize) -> Self {
    let mut res = Sprite{ h:other.h, w:other.w, data:other.data.clone() };
    for yy in 0..self.h { for xx in 0..self.w {
      let c = self.get(yy, xx);
      if c != '.' { res.set(yy+y, xx+x, c) }}}
    res }

}

// -- Game object ---------------------------------------------

struct Game { score: u32, count: u32, matrix:Sprite, active:Sprite, x:usize, y:usize }

impl Game {
  fn new() -> Game {
    Game { score:0, count:0, matrix:Sprite::new_fill(22,10,'.'), active:Sprite::new(1,1,"x"), y:0, x:4}}

  fn clear(&mut self) {
    self.matrix = Sprite::new_fill(22,10,'.') }

  fn get_matrix(&mut self) {
    for y in 0..22 {
      let mut x = 0;
      for c in readln().chars() {
        if c==' ' || c=='\n' {}
        else { self.matrix.set(y,x,c); x+=1 }}}}

  /// step = clear out completed lines
  fn step(&mut self) {
    let mut cleared = vec!(); // vector of indices
    let (h,w) = self.matrix.hw();
    for y in 0..h {
      let i = y * w;
      let row = &self.matrix.data[i..i+w];
      let num_blanks = row.iter().fold(0, |a,c| if *c=='.' {a+1} else {a});
      if num_blanks == 0 { cleared.push(y); }}
    for y in cleared {
      for x in 0..w { self.matrix.set(y,x,'.') }
      self.count += 1; self.score += 100; }}

  fn spawn(&mut self, x:usize, w:usize, s:&str) {
    self.active = Sprite::new(w,w,s); self.x=x; self.y=0; }

  fn nudge(&mut self, dy:i32, dx:i32) {
    if !self.active.collide(&self.matrix, dy+(self.y as i32), dx+(self.x as i32)) {
      self.x = (self.x as i32 + dx) as usize;
      self.y = (self.y as i32 + dy) as usize; }}

}

// -- command interpreter (main) ------------------------------

fn main() {
  let mut g = Game::new();
  loop {
    let s = readln(); let mut chars = s.chars();
    while let Some(c) = chars.next() {
      match c {
        'q' => return,
        'p' => g.matrix.print(),
        'g' => g.get_matrix(),
        'c' => g.clear(),
        's' => g.step(),
        'I' => g.spawn(3,4,"....cccc........"),
        'O' => g.spawn(4,2,"yyyy"),
        'Z' => g.spawn(3,3,"rr..rr..."),
        'S' => g.spawn(3,3,".gggg...."),
        'J' => g.spawn(3,3,"b..bbb..."),
        'L' => g.spawn(3,3,"..oooo..."),
        'T' => g.spawn(3,3,".m.mmm..."),
        ')' => g.active = g.active.cw(),
        '(' => g.active = g.active.cw().cw().cw(),
        '<' => g.nudge(0,-1),
        '>' => g.nudge(0,1),
        'v' => g.nudge(1,0),
        '^' => g.nudge(-1,0),
        't' => g.active.print(),
        'P' => g.active.to_uppercase().onto(&g.matrix, g.y, g.x).print(),
        ';' => println!(""),
        '?' => match chars.next() {
                 Some('s') => println!("{}", g.score),
                 Some('n') => println!("{}", g.count),
                 _ => panic!("expected ('s'|'n') after '?'") }
        _ => {} }}}}
