// use std::io;

fn main() {
  let mut s = String::new();
  std::io::stdin().read_line(&mut s)
    .expect("failed to read input line.");
  for c in s.chars() {
    match c {
      'q' => break,
      'p' => print_matrix(),
      _ => {}
}}}

fn print_matrix() {
  for _ in 0..22 {
    println!(". . . . . . . . . .");
}}
