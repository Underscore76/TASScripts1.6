#!/usr/bin/env python3
"""
Stack Trace Analyzer for Stardew Valley TAS
Aggregates random call stack traces by frame and player to help identify patterns.

Usage:
    python3 trace_analyzer.py randomtraces.txt                    # Basic summary
    python3 trace_analyzer.py randomtraces.txt --patterns         # Include pattern analysis
    python3 trace_analyzer.py randomtraces.txt --detailed         # Show detailed traces
    python3 trace_analyzer.py randomtraces.txt --frame 5110       # Filter by frame
    python3 trace_analyzer.py randomtraces.txt --player 0         # Filter by player
"""

import re
import sys
from collections import defaultdict, Counter
from dataclasses import dataclass
from typing import List, Dict, Optional
import argparse


@dataclass
class StackTrace:
    frame: int
    player: int
    trace_number: int
    stack: List[str]
    random_method: str  # The specific Random method called
    origin_method: str  # The method that triggered the random call


class TraceAnalyzer:
    def __init__(self, filename: str):
        self.filename = filename
        self.traces: List[StackTrace] = []
        self.frame_player_summary: Dict[tuple, Dict] = defaultdict(dict)

    def parse_traces(self):
        """Parse the trace file and extract structured data"""
        try:
            with open(self.filename, "r") as f:
                lines = f.readlines()
        except FileNotFoundError:
            print(f"Error: File '{self.filename}' not found")
            sys.exit(1)
        except Exception as e:
            print(f"Error reading file: {e}")
            sys.exit(1)

        print(f"Processing {len(lines)} lines from {self.filename}")

        current_frame = None
        current_player = None
        current_trace_count = None
        current_stack = []
        trace_index = 0

        for line in lines:
            line = line.rstrip()

            # Frame header
            frame_match = re.match(r"Frame\s+(\d+)", line)
            if frame_match:
                current_frame = int(frame_match.group(1))
                continue

            # Player header
            player_match = re.match(r"\s+Player\s+(\d+)\s+Traces\s+(\d+)", line)
            if player_match:
                current_player = int(player_match.group(1))
                current_trace_count = int(player_match.group(2))
                trace_index = 0
                continue

            # Stack trace line
            if line.startswith("   at "):
                current_stack.append(line[6:])  # Remove "   at " prefix
                continue

            # Empty line indicates end of current trace
            if not line.strip() and current_stack:
                if current_frame is not None and current_player is not None:
                    # Extract random method and origin
                    random_method = self._extract_random_method(current_stack)
                    origin_method = self._extract_origin_method(current_stack)

                    trace = StackTrace(
                        frame=current_frame,
                        player=current_player,
                        trace_number=trace_index,
                        stack=current_stack.copy(),
                        random_method=random_method,
                        origin_method=origin_method,
                    )
                    self.traces.append(trace)
                    trace_index += 1

                current_stack.clear()

    def _extract_random_method(self, stack: List[str]) -> str:
        """Extract the Random method being called"""
        for line in stack:
            if "Random." in line and "_PatchedBy" in line:
                # Extract method name like "Next" or "NextDouble"
                match = re.search(r"Random\.(\w+)_PatchedBy", line)
                if match:
                    return match.group(1)
        return "Unknown"

    def _extract_origin_method(self, stack: List[str]) -> str:
        """Extract the method that ultimately caused the random call"""
        # Look for the first non-Random, non-patch method in the stack
        for line in stack[1:]:  # Skip the first Random call
            if not (
                "Random." in line
                or "_PatchedBy" in line
                or "System.Environment" in line
            ):
                # Extract class and method
                match = re.search(r"at ([^(]+)", line)
                if match:
                    method_full = match.group(1)
                    # Simplify to just class.method
                    parts = method_full.split(".")
                    if len(parts) >= 2:
                        return f"{parts[-2]}.{parts[-1]}"
                    return method_full
        return "Unknown"

    def generate_summary(self):
        """Generate summary statistics by frame and player"""
        for trace in self.traces:
            key = (trace.frame, trace.player)
            if key not in self.frame_player_summary:
                self.frame_player_summary[key] = {
                    "total_traces": 0,
                    "random_methods": Counter(),
                    "origin_methods": Counter(),
                    "unique_stacks": set(),
                    "traces": [],
                }

            summary = self.frame_player_summary[key]
            summary["total_traces"] += 1
            summary["random_methods"][trace.random_method] += 1
            summary["origin_methods"][trace.origin_method] += 1
            summary["unique_stacks"].add(tuple(trace.stack))
            summary["traces"].append(trace)

    def print_overview(self):
        """Print high-level overview"""
        total_traces = len(self.traces)
        frames = set(trace.frame for trace in self.traces)
        players = set(trace.player for trace in self.traces)

        print(f"=== TRACE OVERVIEW ===")
        print(f"Total traces: {total_traces}")
        print(f"Frames: {sorted(frames)}")
        print(f"Players: {sorted(players)}")
        print()

    def print_frame_player_summary(self):
        """Print summary by frame and player"""
        print("=== FRAME/PLAYER SUMMARY ===")
        for (frame, player), summary in sorted(self.frame_player_summary.items()):
            print(f"\nFrame {frame}, Player {player}:")
            print(f"  Total traces: {summary['total_traces']}")
            print(f"  Unique stack patterns: {len(summary['unique_stacks'])}")

            print("  Random methods:")
            for method, count in summary["random_methods"].most_common():
                print(f"    {method}: {count}")

            print("  Origin methods:")
            for method, count in summary["origin_methods"].most_common(5):
                print(f"    {method}: {count}")

    def print_detailed_traces(
        self, frame: Optional[int] = None, player: Optional[int] = None
    ):
        """Print detailed traces for specific frame/player"""
        filtered_traces = self.traces

        if frame is not None:
            filtered_traces = [t for t in filtered_traces if t.frame == frame]
        if player is not None:
            filtered_traces = [t for t in filtered_traces if t.player == player]

        print(f"=== DETAILED TRACES ===")
        if frame is not None or player is not None:
            print(
                f"Filtered for Frame: {frame if frame is not None else 'Any'}, Player: {player if player is not None else 'Any'}"
            )

        for trace in filtered_traces:
            print(
                f"\nFrame {trace.frame}, Player {trace.player}, Trace #{trace.trace_number}"
            )
            print(f"Random Method: {trace.random_method}")
            print(f"Origin Method: {trace.origin_method}")
            print("Stack:")
            for line in trace.stack[:10]:  # Show first 10 lines
                print(f"  {line}")
            if len(trace.stack) > 10:
                print(f"  ... ({len(trace.stack) - 10} more lines)")

    def find_patterns(self):
        """Find common patterns across traces"""
        print("=== PATTERN ANALYSIS ===")

        # Most common random methods
        all_random_methods = Counter(trace.random_method for trace in self.traces)
        print("\nMost common Random methods:")
        for method, count in all_random_methods.most_common(10):
            print(f"  {method}: {count}")

        # Most common origin methods
        all_origin_methods = Counter(trace.origin_method for trace in self.traces)
        print("\nMost common origin methods:")
        for method, count in all_origin_methods.most_common(10):
            print(f"  {method}: {count}")

        # Common stack patterns (first 3 methods)
        stack_patterns = Counter()
        for trace in self.traces:
            if len(trace.stack) >= 3:
                pattern = tuple(line.split("(")[0].strip() for line in trace.stack[:3])
                stack_patterns[pattern] += 1

        print("\nMost common stack patterns (first 3 methods):")
        for pattern, count in stack_patterns.most_common(5):
            print(f"  {count}x: {' -> '.join(pattern)}")


def main():
    parser = argparse.ArgumentParser(
        description="Analyze Stardew Valley TAS random traces"
    )
    parser.add_argument("file", help="Path to the randomtraces.txt file")
    parser.add_argument("--frame", type=int, help="Filter by specific frame")
    parser.add_argument("--player", type=int, help="Filter by specific player")
    parser.add_argument("--detailed", action="store_true", help="Show detailed traces")
    parser.add_argument("--patterns", action="store_true", help="Show pattern analysis")

    args = parser.parse_args()

    print("Starting trace analysis...")
    sys.stdout.flush()

    analyzer = TraceAnalyzer(args.file)
    print("Parsing traces...")
    sys.stdout.flush()
    analyzer.parse_traces()

    print("Generating summary...")
    sys.stdout.flush()
    analyzer.generate_summary()

    # Print results
    analyzer.print_overview()
    analyzer.print_frame_player_summary()

    if args.patterns:
        analyzer.find_patterns()

    if args.detailed:
        analyzer.print_detailed_traces(args.frame, args.player)

    print("\nAnalysis complete!")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
