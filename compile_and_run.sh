#!/bin/bash

# VHDL Compilation and Simulation Script for MicroProcessador
# This script compiles and runs VHDL testbenches using GHDL and visualizes with GTKWave

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$PROJECT_ROOT/work"

# Create work directory if it doesn't exist
mkdir -p "$WORK_DIR"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to compile a single VHDF file
compile_vhdl() {
    local file=$1
    print_info "Compiling: $file"
    ghdl -a --workdir="$WORK_DIR" --work=work "$file" 2>&1 || {
        print_error "Failed to compile $file"
        return 1
    }
}

# Function to elaborate and run a testbench
run_testbench() {
    local entity=$1
    local vcd_name=$2
    
    print_info "Elaborating entity: $entity"
    ghdl -e --workdir="$WORK_DIR" --work=work "$entity" 2>&1 || {
        print_error "Failed to elaborate $entity"
        return 1
    }
    
    print_info "Running simulation for: $entity"
    ghdl -r --workdir="$WORK_DIR" --work=work "$entity" --vcd="$WORK_DIR/$vcd_name.vcd" 2>&1 || {
        print_error "Failed to run $entity"
        return 1
    }
    
    print_success "Generated VCD: $WORK_DIR/$vcd_name.vcd"
}

# Function to open VCD in GTKWave
open_gtkwave() {
    local vcd_file=$1
    if [ -f "$vcd_file" ]; then
        print_info "Opening $vcd_file in GTKWave..."
        gtkwave "$vcd_file" &
    else
        print_error "VCD file not found: $vcd_file"
        return 1
    fi
}

# Function to compile and run a complete module (entity + testbench)
compile_and_run_module() {
    local module_path=$1
    local entity_name=$2
    local testbench_name=$3
    local vcd_name=$4
    
    echo ""
    print_info "=========================================="
    print_info "Processing module: $entity_name"
    print_info "=========================================="
    
    # Compile entity
    if [ -f "$module_path/$entity_name.vhd" ]; then
        compile_vhdl "$module_path/$entity_name.vhd"
    fi
    
    # Compile testbench
    if [ -f "$module_path/$testbench_name.vhd" ]; then
        compile_vhdl "$module_path/$testbench_name.vhd"
    else
        print_warning "Testbench not found: $module_path/$testbench_name.vhd"
        return 1
    fi
    
    # Run testbench
    run_testbench "$testbench_name" "$vcd_name"
}

# Display usage
usage() {
    cat << EOF
${BLUE}Usage: $0 [OPTION]${NC}

Options:
    all                  Compile and run all modules
    fsm                  Compile and run FSM module
    memoria              Compile and run Memoria (ROM) module
    pc                   Compile and run Program Counter module
    ula                  Compile and run ULA module
    register             Compile and run Register Bank module
    uc                   Compile and run Control Unit module
    processor            Compile and run complete Processor testbench
    clean                Clean work directory
    help                 Display this help message

Examples:
    $0 fsm               # Compile and run FSM testbench
    $0 all               # Compile and run all modules
    $0 processor --view  # Run processor and open in GTKWave
EOF
}

# Main script logic
main() {
    local target="${1:-help}"
    local open_view="${2:---view}"
    
    case "$target" in
        all)
            print_info "Compiling and running ALL modules..."
            compile_and_run_module "$PROJECT_ROOT/FSM" "fsm_state" "fsm_tb" "fsm_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/fsm_sim.vcd"
            compile_and_run_module "$PROJECT_ROOT/Memoria" "rom" "tb_rom" "memoria_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/memoria_sim.vcd"
            compile_and_run_module "$PROJECT_ROOT/ProgramCounter" "ProgramCounter" "tb_PCCounterTop" "pc_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/pc_sim.vcd"
            compile_and_run_module "$PROJECT_ROOT/ULA" "ALU" "ALU_tb" "ula_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/ula_sim.vcd"
            compile_and_run_module "$PROJECT_ROOT/RegisterBank" "RegisterBank" "register_bank_tb" "register_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/register_sim.vcd"
            compile_and_run_module "$PROJECT_ROOT/UC" "UC" "tb_uc" "uc_sim" && [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/uc_sim.vcd"
            ;;
        fsm)
            compile_and_run_module "$PROJECT_ROOT/FSM" "fsm_state" "fsm_tb" "fsm_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/fsm_sim.vcd"
            ;;
        memoria)
            compile_and_run_module "$PROJECT_ROOT/Memoria" "rom" "tb_rom" "memoria_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/memoria_sim.vcd"
            ;;
        pc)
            compile_and_run_module "$PROJECT_ROOT/ProgramCounter" "ProgramCounter" "tb_PCCounterTop" "pc_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/pc_sim.vcd"
            ;;
        ula)
            compile_and_run_module "$PROJECT_ROOT/ULA" "ALU" "ALU_tb" "ula_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/ula_sim.vcd"
            ;;
        register)
            compile_and_run_module "$PROJECT_ROOT/RegisterBank" "RegisterBank" "register_bank_tb" "register_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/register_sim.vcd"
            ;;
        uc)
            compile_and_run_module "$PROJECT_ROOT/UC" "UC" "tb_uc" "uc_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/uc_sim.vcd"
            ;;
            
        # ==========================================================
        # SEÇÃO 'processor' MODIFICADA
        # ==========================================================
        processor)
            print_info "=========================================="
            print_info "Compiling complete Processor testbench"
            print_info "=========================================="
            
            # === ADIÇÃO SOLICITADA ===
            # Compila o PSW *antes* de compilar o resto,
            # para garantir que a dependência da UC seja resolvida.
            print_info "Compiling dependency: psw.vhd"
            compile_vhdl "$PROJECT_ROOT/UC/psw.vhd"
            
            # Compila todas as outras dependências
            print_info "Compiling remaining entities..."
            find "$PROJECT_ROOT" -name "*.vhd" \
                ! -path "*/UC/psw.vhd" \
                ! -name "*_tb.vhd" \
                ! -name "tb_*.vhd" -type f | while read file; do
                compile_vhdl "$file"
            done
            
            # Compila os testbenches
            print_info "Compiling testbenches..."
            find "$PROJECT_ROOT" -name "*_tb.vhd" -o -name "tb_*.vhd" -type f | while read file; do
                compile_vhdl "$file"
            done
            
            # Executa o testbench do processador
            run_testbench "processador_tb" "processor_sim"
            [ "$open_view" == "--view" ] && open_gtkwave "$WORK_DIR/processor_sim.vcd"
            ;;
        # ==========================================================
        
        clean)
            print_info "Cleaning work directory..."
            rm -rf "$WORK_DIR"
            mkdir -p "$WORK_DIR"
            print_success "Work directory cleaned"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown option: $target"
            usage
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_success "Process completed successfully!"
    else
        print_error "Process failed!"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"