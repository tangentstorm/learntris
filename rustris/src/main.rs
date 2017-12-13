use std::io;

fn readln() -> String {
  let mut s = String::new();
  io::stdin().read_line(&mut s)
    .expect("failed to read input line.");
  s }

fn main() {
  loop {
    let s = readln();
    for c in s.chars() {
      match c {
        'q' => return,
        'p' => print_matrix(),
        'g' => for _ in 0..22 { readln(); }
        _ => {} }}}}

fn print_matrix() {
  for _ in 0..22 {
    println!(". . . . . . . . . ."); }}
