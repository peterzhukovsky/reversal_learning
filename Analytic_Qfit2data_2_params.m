%% Data Import and Fitting the PDFs to the data
%data=readtable('left_right_qmodelling.txt');]
subject_list= [ 1     2     3     4];
for subject=subject_list;    %loop for all subjects
    %Import data
    data=readtable(strcat('%% WORKING DIRECTORY WITH THE TEXT FILES CONTAINING DATA HERE', num2str(subject), '.txt'));

clear C               Q_right                block_history   reward_history
clear Prob_choice_l   Resp               ntrials         total_Q_left  
clear Prob_choice_r   response        total_Q_right   
clear Q_left         block           reward          trial    PDF 
clear f alpha_l_R beta PDF_FUNCTION PDF_min PDF_minval Prob_sequence
%1. load up reward and responses
response=data.Var2; % alternatively you can feed it response and reward data here directly
reward=data.Var3;
  
%dummy variables
ntrials=length(response); %change to 1000
%total_Q_left=sym(zeros(1,ntrials)');
total_Q_left=zeros(1,ntrials,'sym')';
total_Q_right=zeros(1,ntrials,'sym')';
%total_Q_right=sym(zeros(1,ntrials)');
Q_left=zeros(1,ntrials,'sym')';
Q_right=zeros(1,ntrials,'sym')';

%Q_left=sym(zeros(1,ntrials)');
Q_left(1)=0;
%Q_right=sym(zeros(1,ntrials)');
Q_right(1)=0;

syms alpha_l_R beta real
for trial=1:ntrials;   %loop for all trials in the data
    trial
    %1. define Q value for Q_left Q_right
    %total is calculated over all previous trials
    total_Q_left(trial)=simplify(sum([Q_left(1:trial)])); %total Q value at a trial
    total_Q_right(trial)=simplify(sum([Q_right(1:trial)]));
    %updating the Q-value for "left" and "right" based on the response made
    if response(trial)==1;
            Q_left(trial)=alpha_l_R*(reward(trial)-total_Q_left(trial)); %trial wise change in association strength aka Q value at a trial
    elseif response(trial)==2;
            Q_right(trial)=alpha_l_R*(reward(trial)-total_Q_right(trial)); %can use separate values for left and right if needed
    end
    
    %3. Use Q value in softmax probability rule for decision making based on q value
    %softmaxrule for calculating probability of choosing a response
    Prob_choice_l(trial+1)=exp(total_Q_left(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
    Prob_choice_r(trial+1)=exp(total_Q_right(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
    Prob_choice_l(trial+1)=simplify(Prob_choice_l(trial+1));
    Prob_choice_r(trial+1)=simplify(Prob_choice_r(trial+1));
end %end of the for loop going for each trial

Prob_sequence=zeros(1, length(response),'sym');
for trial=2:(length(Prob_choice_l)-1);
    if response(trial)==1;
        Prob_sequence(trial)=Prob_choice_l(trial);
    else
        Prob_sequence(trial)=Prob_choice_r(trial);        
    end
    Prob_sequence(1)=0.5;
end
%probability of each response in the sequence at each trial
PDF=log(prod(Prob_sequence));
syms f(alpha_l_R, beta)
f(alpha_l_R, beta) = PDF;
%df = diff(f,alpha_l_R, beta)


%possible but not necesary for optimization
%grad_f=gradient(f);
%figure(2)
%ezsurfc(grad_f, [0.2 2])
%diary('myfunction.txt')
%PDF_FUNCTION = matlabFunction(-PDF)
%diary off

x=[alpha_l_R; beta];
PDF_FUNCTION = matlabFunction(-PDF, 'vars', {x})

%x0=[0; 1]
%PDF_min = fminsearch(PDF_FUNCTION,x0)

A = [];
b = [];
Aeq = [];
beq = [];
lb = [0, 0];
ub = [1 , 5];
x0 = [0.5; 0.5];

%xrange1=0:0.2:1;
%xrange2=0:0.3:3;
%for i=1:length(xrange1);
 %   for j=1:length(xrange2);
 %   x0=[xrange1(i); xrange2(j)];
  %  [PDF_min, PDF_minval] = fmincon(PDF_FUNCTION,x0,A,b,Aeq,beq,lb,ub);
  %  PDF_min_optimalval(i,j,:)=PDF_minval;
  %  PDF_min_optimal(i,j,:)=PDF_min;
  %  end
%end


[PDF_min, PDF_minval] = fmincon(PDF_FUNCTION,x0,A,b,Aeq,beq,lb,ub)
best_fit_params(subject,:)=PDF_min;
%fun = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
%x=fminsearch(fun, x0)
%x=fmincon(PDF_FUNCTION, x0,A,b,Aeq,beq,lb,ub)
BIC=-PDF_minval-length(x)/2*log(length(response))
BIC_all(subject)=BIC;
%https://uk.mathworks.com/help/symbolic/diff.html
%https://uk.mathworks.com/company/newsletters/articles/optimization-using-symbolic-derivatives.html
%https://uk.mathworks.com/help/optim/examples/using-symbolic-mathematics-with-optimization-toolbox-solvers.html

%https://uk.mathworks.com/help/symbolic/symfun.html
%PLOTTING THE PDF + max 
ezsurfc(f, [0 2])
zminlim=-PDF_minval-5;
zmaxlim=-PDF_minval+2;
zlim([zminlim zmaxlim])
ylim([0 2])
xlim([0 1])


%random model
r=log(0.5^(length(response)));
    %Q model fit vs random model
    pseudo_R2(subject)=(-PDF_minval-r)/r;


%save data for each subject
%PDF_all(subject)={PDF};
%pseudo_R2_all(subject)={pseudo_R2};
end %end the loop for all subjects

pseudo_R2=pseudo_R2'
BIC_all=BIC_all
        
