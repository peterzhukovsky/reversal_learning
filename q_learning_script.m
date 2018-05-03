k=0.01:0.3:1;
index=allcomb(k,k,k);
for l=1:length(index);
    alpha_l_R=index(l,1,1);
    alpha_l_noR=index(l,2,1);
    beta= index(l,3,1);
    
for iteration=1:100;
clear C               Q_right                block_history   reward_history
clear Prob_choice_l   Resp               ntrials         total_Q_left  
clear Prob_choice_r   response        total_Q_right   
clear Q_left         block           reward          trial    

%dummy variables
Q_left=zeros(1,1000)';
Q_right=zeros(1,1000)';
reward_history =zeros(1,1000)';
block_history =zeros(1,1000)';
%actual variables initialisation
ntrials=1000; %change to 1000
block = 1; %starting block, changes later in script
reward=1; %change reward
    Resp=[1 2]; %randomise starting response
    C = cumsum([0.5 0.5]); %
    response(1) = Resp(1+sum(C(end)*rand>C)); %dont randomise for this rat

    %stop after block=4 reached!
%create a loop for all trials
for trial=1:ntrials;
    %1. define reward
    %via defining block
    if response(trial)==1 & (block==1 | block==3);
        reward=1;
    elseif response(trial)==2 & (block==2 | block==4);
        reward=1;
    else
        reward=0;
    end
    reward_history(trial)=reward;   
    block_history(trial)=block;
    
    if sum(reward_history)>=10
        if sum([reward_history((trial-9):trial)])>=9 && block_history(trial)==block_history(trial-9);
            block = block+1;
        end;
    else block=1;
    end
        
    %define reward itself

    %run a for loop until condition is met
%2. define Q value for Q_left Q_right
    %total is calculated over all previous trials
    total_Q_left(trial)=sum([Q_left(1:trial)]); %total Q value at a trial
    total_Q_right(trial)=sum([Q_right(1:trial)]);
    %updating the Q-value for "left" and "right" based on the response made
    if response(trial)==1;
        if reward==1 
            Q_left(trial)=alpha_l_R*(reward-total_Q_left(trial)); %trial wise change in association strength aka Q value at a trial
        else 
            Q_left(trial)=alpha_l_noR*(reward-total_Q_left(trial)); 
        end
    elseif response(trial)==2;
        if reward==1
            Q_right(trial)=alpha_l_R*(reward-total_Q_right(trial)); %can use separate values for left and right if needed
        else
            Q_right(trial)=alpha_l_noR*(reward-total_Q_right(trial)); %can use separate values for left and right if needed
        end
    end 
    
%3. Use Q value in softmax probability rule for decision making based on q value
    %softmaxrule for calculating probability of choosing a response
    Prob_choice_l(trial)=exp(total_Q_left(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
    Prob_choice_r(trial)=exp(total_Q_right(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
    %choosing a response: https://uk.mathworks.com/matlabcentral/answers/23319-easy-question-with-probability
    Resp=[1 2];
    C = cumsum([Prob_choice_l(trial) Prob_choice_r(trial)]);
    %response chosen for trial+1 as it's based on Q values from trial "trial"
    response(trial+1) = Resp(1+sum(C(end)*rand>C));
    
    %finish loop once block 4 reached, ie all 3 reversals R>L>R>L or the reverse completed
    if block==4;
        break;
    end;

end %end of the for loop going for each trial
response=response(1:trial)';
%saving data: response data saved
response_summary(iteration)={response};
P_L_summary(iteration)={Prob_choice_l};
P_R_summary(iteration)={Prob_choice_r};
end %end the iterations over the same parameters

%%%%% save the data for each run and automate for alpha_R vs alpha_noR and
%%%%% beta
summary(l)={response_summary};
end


