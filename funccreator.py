def main():
    funcname = input("function name: ")

    print(f"""
    function NPC:Custom{funcname}() 
        
    
    end

    function NPC:{funcname}() 
        self:Custom{funcname}() 
    end
    """)


if __name__ == "__main__":
    main()