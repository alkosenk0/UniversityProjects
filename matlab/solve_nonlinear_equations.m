format short;
clc;

main();
    
function [y] = f(x, num)
    F = {@(x) 2*x.^4-8*x.^3+8*x.^2-1;
         @(x) 2*atan(x) - x+3};
    y = F{num}(x);
end 

function [y] = derivatives_f(x, num, k)
    F = {{@(x) 8*x.^3 - 24*x^2 + 16*x;
          @(x) 24*x.^2 - 48*x + 16};
         {@(x) 2/(1+x.^2) - 1;
          @(x) (4*x)/((1-x.^2)^2)}};
    y = F{num}{k}(x);
end

function [] = main()
    eps = 1e-12;
    round_num = 3;
    step = 0.1;
    x = -pi:step:2*pi;
    titles = {'f(x) = 2x^4 - 8x^3 + 8x^2 - 1', 'f(x) = 2arctg(x) - x + 3'};
    colors = {'r', 'g', 'b'};

    count_func = size(titles);

    for j=1:count_func(2)
        am_dicho = 0; am_hord = 0; 
        am_newt = 0; am_comb = 0;

        subplot(count_func(2), 1, j);

        colors_size = size(colors);
        const = mod(j, colors_size(2));
        if const == 0
            const = const + 1;
        end
        color = colors{const};

        plot(x, f(x, j), color);
        hold on; grid on;

        title(titles{j});

        solutions = search_solutions(x, j);
        size_sol = size(solutions);

        testing = 1;

        size_x = size(x);

        for i=1:size_sol(1)
            [root_dicho, iter_dicho] = dichotomy(solutions(i, 1), ...
                                               solutions(i, 2), eps, j);
            [root_hord, iter_hord] = hord(solutions(i, 1), ... 
                                          solutions(i, 2), eps, j);
            [root_newt, iter_newt] = newton(solutions(i, 1), ... 
                                          solutions(i, 2), eps, j);
            [root_comb, iter_comb] = combo(solutions(i, 1), ... 
                                          solutions(i, 2), eps, j);

            myfunc = @(x, j) f(x, j); % parameterized function
            fun = @(x) myfunc(x, j); % function of x alone
            fzero_ = fzero(fun,  [solutions(i, 1) solutions(i, 2)]);

            plot(root_dicho, f(root_dicho, j), 'x');
            plot(root_hord, f(root_hord, j), '+');
            plot(root_newt, f(root_newt, j), '*');
            plot(root_comb, f(root_comb, j), 'o');
            plot(fzero_, f(fzero_, j), 's');

            am_dicho = am_dicho + iter_dicho;
            am_hord = am_hord + iter_hord;
            am_newt = am_newt + iter_newt;
            am_comb = am_comb + iter_comb;

            if not(round(root_hord, round_num) == round(root_hord, round_num) && ...
                   round(root_hord, round_num) == round(fzero_, round_num) && ...
                   round(fzero_, round_num) == round(root_newt, round_num) && ...
                   round(root_newt, round_num) == round(root_comb, round_num))
                testing = 0;
            end
            if j == 1
                root_polynomial = roots([2 -8 8 0 -1]);
                size_root_pol = size(root_polynomial);
                if not(round(root_newt, round_num) == ...
                        round(root_polynomial(size_root_pol(1)-i+1), round_num))
                    testing = 0;
                end
            end
        end
        fprintf('\nFunction - %s.\n', titles{j});
        fprintf('Founded solutions - %d from a = %f to b = %f with step - %.2f.\n', ...
                                           size_sol(1), x(1), x(size_x(2)), step);
        fprintf('Iterations: dichotomy - %d, hord - %d, newton - %d, combo method - %d.\n', ...
                                           am_dicho, am_hord, am_newt, am_comb);
        
        if testing, test = 'True'; else, test = 'False'; end 
        fprintf('Values of dichotomy, hord and root/fzero equivalent = %s.\n', test);    
    end
end

function [c, iterations] = dichotomy(a, b, eps, num)
    iterations = 0;
    c = 0;
    if f(a, num)*f(b, num) < 0
        c = (a+b)/2;
        while abs(f(c, num)) > eps
            if f(c, num)*f(a, num) > 0
                a = c;
            else
                b = c;
            end
            c = (a+b)/2;
            iterations = iterations + 1;
        end
    end  
end

function [c, iterations] = hord(a, b, eps, num)
    c = a - ((f(a, num))/(f(b, num) - f(a, num)))*(b - a);
    iterations = 0;
    while abs(f(c, num)) > eps
        c = a - ((f(a, num))/(f(b, num) - f(a, num)))*(b - a);
        if f(a, num)*f(c, num) < 0
            b = c;
        else
            a = c;
        end
        iterations = iterations + 1;
    end
end

function [c, iterations] = newton(a, b, eps, num)
    iterations = 0;
    if f(a, num)*derivatives_f(a, num, 2) > 0
        x = a;
    else
        x = b;
    end
    c = x - (f(x, num)/derivatives_f(x, num, 1));
    while abs(f(c, num)) > eps
        c = x - (f(x, num)/derivatives_f(x, num, 1));
        x = c;
        iterations = iterations + 1;
    end
end

function [c, iterations] = combo(a, b, eps, num)
    iterations = 0;
    if f(a, num)*derivatives_f(a, num, 2) > 0
        c = a;
    elseif f(a, num)*derivatives_f(a, num, 2) < 0
        c = b;
    end
    xn = c - (f(c, num)/derivatives_f(c, num, 1));
    x = a - ((f(a, num))/(f(b, num) - f(a, num)))*(b - a);
    
    while (abs(xn-x) > eps)
        xn = c - (f(c, num)/derivatives_f(c, num, 1));
        c = xn;
        
        x = a - ((f(a, num))/(f(b, num) - f(a, num)))*(b - a);    
        if f(a, num)*f(x, num) < 0
            b = x;
        else
            a = x;
        end
        iterations = iterations + 1;
    end
end

function [Array] = search_solutions(x, num)
    n = size(x);
    prev_y = 0;
    solutions = 0;
    Array = [];
    for i=1:n(2)
        value = x(1, i);
        y = f(value, num);
        if prev_y*y < 0
            Array = [Array; x(1, i-1) value]; %#ok<*AGROW>
            solutions = solutions + 1;
        end
        prev_y = y;
    end
end