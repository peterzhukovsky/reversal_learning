%% Data Import and Fitting the PDFs to the data
%data=readtable('left_right_qmodelling.txt');]
subject_list= [ 1     2     3     4     5    6     7     8     9    10    11    12    13     14    15    16    17  18    19    20    21    23    24];
for subject=subject_list;    %loop for all subjects
    %Import data
    data=readtable(strcat(num2str(subject), '.txt'));

clear C               Q_right                block_history   reward_history
clear Prob_choice_l   Resp               ntrials         total_Q_left  
clear Prob_choice_r   response        total_Q_right   
clear Q_left         block           reward          trial    PDF

%1. load up reward and responses
response=data.Var1; % alternatively you can feed it response and reward data here directly
reward=data.Var2;
j=0.001:0.02:1;
k=0.005:0.08:5;
index=allcomb(j,k);
for l=1:length(index);      %loop for all combinations of the parameters
    alpha_l_R=index(l,1,1);
    beta=index(l,2,1);
    
%dummy variables
Q_left=zeros(1,1000)';
Q_left(1)=0;
Q_right=zeros(1,1000)';
Q_right(1)=0;
ntrials=length(response); %change to 1000
for trial=1:ntrials;   %loop for all trials in the data
    %1. define Q value for Q_left Q_right
    %total is calculated over all previous trials
    total_Q_left(trial)=sum([Q_left(1:trial)]); %total Q value at a trial
    total_Q_right(trial)=sum([Q_right(1:trial)]);
    %updating the Q-value for "left" and "right" based on the response made
    if response(trial)==1;
        if reward(trial)==1 
            Q_left(trial)=alpha_l_R*(reward(trial)-total_Q_left(trial)); %trial wise change in association strength aka Q value at a trial
        else 
            Q_left(trial)=alpha_l_R*(reward(trial)-total_Q_left(trial)); 
        end
    elseif response(trial)==2;
        if reward(trial)==1
            Q_right(trial)=alpha_l_R*(reward(trial)-total_Q_right(trial)); %can use separate values for left and right if needed
        else
            Q_right(trial)=alpha_l_R*(reward(trial)-total_Q_right(trial)); %can use separate values for left and right if needed
        end
    end 
    
%3. Use Q value in softmax probability rule for decision making based on q value
    %softmaxrule for calculating probability of choosing a response
    Prob_choice_l(trial+1)=exp(total_Q_left(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
    Prob_choice_r(trial+1)=exp(total_Q_right(trial)/beta)/(exp(total_Q_left(trial)/beta)+exp(total_Q_right(trial)/beta));
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

%% PARAMETER OPTIMIZATION
%exploring the PDF for each subject for each parameter combination (from index) to find the best fit parameters
PDF=PDF';

best_fit_params=zeros(2,length(subject_list))';
R2_fit=zeros(1,length(subject_list));
PDF_all_cut=PDF_all;
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
chi2inv(.95, 1)

%% Plotting the PDF in 2D
%best_fit_params saved for each subject on a row
%visualise
subject=1;
plot3(index(:,1), index(:,2), PDF_all{1,subject});
upperl=max(PDF_all{1,subject})+5;
lowerl=max(PDF_all{1,subject})-10;
zlim([lowerl upperl]);
        xlabel('alpha');
        ylabel('beta');
        zlabel('log(P(D|M,?)');
hold on
subject=4;
plot3(index(:,1), index(:,2), PDF_all{1,subject});


%% %plotting some data as an example, e.g. total Q values for left
            %and right
            figure(3)
            plot(total_Q_left)
            hold on
            plot(total_Q_right)
            
            %plotting Prob_choice for L and R; together with observed
            %responses - see how good your params are at predicting data
            %bear in mind this is for the last set of params
            figure(2)
            plot(Prob_choice_l)
            hold on
            plot(Prob_choice_r)
            hold on
            plot(response)

        
