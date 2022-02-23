function read_file(fname)
    Dataset = Array[]
    file_read= open(fname, "r")
    for line in eachline(file_read)
        temp = Int[]
        for i in (split(line))
            push!(temp, parse(Int,i))
        end
        push!(Dataset, temp)
    end
    close(file_read)
    return Dataset
end

function subset(x)
    result = Array[]
    for i in x
        tmp = setdiff(x, i)
        push!(result, tmp)
    end
    return result
end

function powerset(x::Vector{T}) where T
    result = Vector{T}[[]]
    for elem in x, j in eachindex(result)
        push!(result, [result[j] ; elem])
    end
    return result
end

function Apriori_Algorithm(itemsets, minSup)
    num_minSup = minSup/100*length(itemsets)

    Ck = Dict() # Su dung Ck va Ck1 tuong duong C(k) va C(k+1)
    Lk = Dict() # Su dung Lk va Lk1 tuong duong L(k) va L(k+1)
    L = Dict()

    # Duyet D -> C1:
    for i in itemsets, j in i
        Ck[j] = get(Ck, j, 0) + 1
    end
    # Tao L1
    for i in keys(Ck)
        if Ck[i] >= num_minSup
            Lk[i] = Ck[i]
        end
    end
    # Them Lk vao L
    for i in keys(Lk)
        L[i] = Lk[i]
    end
    k = 2
    while(true)
        Lk1 = Dict()
        Ck1 = Dict()

        # 1.1 Phat sinh C(k+1) tu L(k)
        for i in 1:length(Lk), j in i+1:length(Lk)
            x = union(collect(keys(Lk))[i, 1], collect(keys(Lk))[j, 1])
            x = sort(x)
            if (length(x) <= k) && (!).(x in keys(Ck1))
                Ck1[x] = get(Ck1, x, 0)
            end
        end
        # 1.2 Cat tia
        for i in keys(Ck1), j in subset(i)
            if (j[1,1] ∉ (keys(Lk)) && j ∉ (keys(Lk)))
                delete!(Ck1, i)
            end
        end
        # 1.3 Kiem tra Ket thuc thuat toan
        if Ck1.count == 0
            break
        end
        # 2. Duyet C(k+1) qua Dataset
        for i in keys(Ck1), j in itemsets
            if issubset(i, j)
                Ck1[i]+=1
            end
        end
        # 3. Tao L(k+1)
        for i in keys(Ck1)
            if Ck1[i] >= num_minSup
                Lk1[i] = Ck1[i]
            end
        end

        # 4. Add L(k+1) vao L
        for i in keys(Lk1)
            L[i] = Lk1[i]
        end

        Ck = Ck1
        Lk = Lk1
        k+=1
    end
    return L, Lk
end

function RuleGeneration(itemset, frequent, minConf)
    if length(keys(frequent)) == 0
        println("Khong co tap pho bien, khong phat sinh Luat.")
        return
    elseif length(collect(keys(frequent))[1,1]) == 1
        println("Tap pho bien co 1 item, khong phat sinh Luat.")
        return
    end
    x = powerset(collect(keys(frequent))[1,1])[2:end,1]
    counter = Dict()
    for i in x, j in itemset
        if issubset(i, j)
            counter[i] = get(counter, i, 0) + 1
        end
    end

    for i in 1:length(x)-2
        if counter[sort(union(x[i, 1], x[i+1, 1]))]*100/counter[x[i, 1]] >= minConf
            println(x[i, 1], " ==> ", 
                x[i+1, 1], " : ",
                round(counter[sort(union(x[i, 1], x[i+1, 1]))]*100/counter[x[i, 1]], digits=2), "%")
        end
        if counter[sort(union(x[i+1, 1], x[i, 1]))]*100/counter[x[i+1, 1]] >= minConf
            println(x[i+1, 1], " ==> ", 
                x[i, 1], " : ",
                round(counter[sort(union(x[i+1, 1], x[i, 1]))]*100/counter[x[i+1, 1]], digits=2), "%")
        end
    end
end

function run_main()
    try
        fname = ARGS[1]
        minSup = parse(Float64,ARGS[2])
        minConf = parse(Float64,ARGS[3])
        itemset = read_file(fname)
        tmp, frequent = Apriori_Algorithm(itemset, minSup)
        println("[FREQUENT ITEMSET]:")
        for (key, value) in frequent
            println(key, " ==> ", value)
        end
        println("[ASSOCIATION RULE]:")
        RuleGeneration(itemset,frequent, minConf)
        println("----------------------")        
    catch err
        println("Co loi, thu lai.")
    end
end

@time run_main()