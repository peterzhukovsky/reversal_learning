%data=readtable('left_right_qmodelling.txt');]
subject_list= [ 1     2     3     4     5    6     7     8     9    10    11    12    13     14    15    16    17  18    19    20    21    23    24];
for subject=subject_list;    %loop for all subjects
    %Import data
    data=readtable(strcat('C:/Users/Peter/Documents/MATLAB/reversal_modelling/pre_sugar_data/', num2str(subject), '.txt'));

clear C               Q_right                block_history   reward_history
clear Prob_choice_l   Resp               ntrials         total_Q_left  
clear Prob_choice_r   response        total_Q_right   
clear Q_left         block           reward          trial    PDF

%1. load up reward and responses
response=data.Var1; % alternatively you can feed it response and reward data here directly
reward=data.Var2;
reward_mean=mean(reward);
%j=0.001:0.02:1;
k=0.005:0.08:5;
index=k';
for l=1:length(index);      %loop for all combinations of the parameters
    beta=index(l,1);
    
%dummy variables
total_pi_left=zeros(1,length(response))';
total_pi_right=zeros(1,length(response))';
ntrials=length(response); %change to 1000
for trial=1:ntrials;   %loop for all trials in the data
    %1. define Q value for Q_left Q_right
    %total is calculated over all previous trials
    %total_pi_left(trial)=sum([pi_left(1:trial)]); %total Q value at a trial
    %total_pi_right(trial)=sum([pi_right(1:trial)]);
    %updating the Q-value for "left" and "right" based on the response made
    if response(trial)==1;
            total_pi_left(trial+1)=total_pi_left(trial)+(reward(trial)-reward_mean); %trial wise change in association strength aka Q value at a trial
    elseif response(trial)==2;
            total_pi_right(trial+1)=total_pi_right(trial)+(reward(trial)-reward_mean); %can use separate values for left and right if needed
    end 
    
%3. Use Q value in softmax probability rule for decision making based on q value
    %softmaxrule for calculating probability of choosing a response
    Prob_choice_l(trial+1)=exp(total_pi_left(trial)/beta)/(exp(total_pi_left(trial)/beta)+exp(total_pi_right(trial)/beta));
    Prob_choice_r(trial+1)=exp(total_pi_right(trial)/beta)/(exp(total_pi_left(trial)/beta)+exp(total_pi_right(trial)/beta));
end %end of the for loop going for each trial

Prob_sequence=zeros(1, length(response));
for trial=2:(length(Prob_choice_l)-1);
    if response(trial)==1;
        Prob_sequence(trial)=Prob_choice_l(trial);
    else
        Prob_sequence(trial)=Prob_choice_r(trial);        
    end
    Prob_sequence(1)=0.5;
end
%probability of each response in the sequence at each trial
PDF(l)=log(prod(Prob_sequence));

%random model
r=log(0.5^(length(response)));
    %Q model fit vs random model
    pseudo_R2(l)=(PDF(l)-r)/r;
end %end the iterations over the same parameters

%save data for each subject
PDF_all(subject)={PDF};
pseudo_R2_all(subject)={pseudo_R2};
end %end the loop for all subjects

%% Parameter optimization
%exploring the PDF for each subject for each parameter combination (from index) to find the best fit parameters
PDF=PDF';
PDF_all_cut=PDF_all;
best_fit_params=zeros(1,length(subject_list))';
R2_fit=zeros(1,length(subject_list));
for subject=subject_list
    for row=1:length(PDF);
    
        if PDF_all{1,subject}(row) == (max(PDF_all{1,subject}));  %+max(PDF_all{1,subject})*0.0000005);
            best_fit_params(subject,:,:)=(index(row,:,:));
            R2_fit(subject)=pseudo_R2_all{1,subject}(row);
        end
        
    end
    PDF_all_cut{1,subject}(~isfinite(PDF_all_cut{1,subject}))=[];
    Model_evidence(subject)=mean(PDF_all_cut{1,subject});
    d(subject)=max(PDF_all{1,subject});
end

Model_evidence=Model_evidence';
R2_fit=R2_fit';
d=d';
%best_fit_params saved for each subject on a row
subject=1;
plot(index(:,1), PDF_all{1,subject});
upperl=max(PDF_all{1,subject})+5;
lowerl=max(PDF_all{1,subject})-10;
ylim([lowerl upperl]);
        xlabel('beta');
        ylabel('log(P(D|M,?)');
hold on;
    subject=2;
    plot(index(:,1), PDF_all{1,subject});
    hold on;
   subject=4;
    plot(index(:,1), PDF_all{1,subject});
    hold on;
   subject=5;
    plot(index(:,1), PDF_all{1,subject});
   
%% %plotting some data as an example, e.g. total Q values for left
            %and right
            figure(3)
            plot(total_pi_left)
            hold on
            plot(total_pi_right)
            
            %plotting Prob_choice for L and R; together with observed
            %responses - see how good your params are at predicting data
            %bear in mind this is for the last set of params
            figure(2)
            plot(Prob_choice_l)
            hold on
            plot(Prob_choice_r)
            hold on
            plot(response)
            
            
            
            