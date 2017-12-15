package TestPlugin;

use strict;
use Log qw(message);
use Plugins;
use Globals;


Plugins::register("test", "test for test", \&onUnload);
my $hooks = Plugins::addHooks(
                ["AI_pre", \&onAI]
            );

sub onUnload {
    Plugins::delHooks($hooks);
}

my $disabled = 0;
my $timeNow1 = time;
my $timeNow2 = time;
my $delay = 5;
my $minAmount = 1000;
my $arrowName = "Fire Arrow";
my $materialName = "Burning Heart";
my $oldAttackAuto = -999;
my $nowAttackAuto = -999;

sub onAI {
    if (!$disabled && main::timeOut($timeNow2, 1)) {
#EATCARROT_BEGIN:
        if ($char->hp_percent > 70) {
            goto EATCARROT_END;
        }
        my $item = $char->inventory->getByName("Carrot");
        if ((!$item) || ($item->{amount} < 5) ){
            goto RESPAWN;
        }

        my $rudolf = $char->inventory->getByName("Rudolf Hairband");
        if (!$rudolf->{equipped}) {
            $rudolf->equip;
        };

        $item->use;
        $item->use;
        $item->use;
        $item->use;
        $item->use;
EATCARROT_END:
#STOP ATTACK WHEN AT RISK
        if ($char->hp_percent < 40) {
            if ($oldAttackAuto == -999) {
                $oldAttackAuto = $::config{attackAuto};
                $nowAttackAuto = $oldAttackAuto;
            }  
            if ($nowAttackAuto != -1) {
                $oldAttackAuto = $nowAttackAuto;
                $nowAttackAuto = -1;
                Commands::run("conf attackAuto 0");
            }
        }
        if ($char->hp_percent > 60) {
            if ($nowAttackAuto == -1) {
                $nowAttackAuto = $oldAttackAuto;
                Commands::run("conf attackAuto ".$oldAttackAuto);
                $oldAttackAuto = -999;
            }
        }
        $timeNow2 = time;
        
    }

    if (!$disabled && main::timeOut($timeNow1, $delay)) {

#ARROWCRAFT_BEGIN:
        my $material = $char->inventory->getByName($materialName);
        if ((!$material) || ($material->{amount} < 5) ){
            goto RESPAWN;
        }

        my $arrow = $char->inventory->getByName($arrowName);
        if (($arrow && $arrow->{amount} > $minAmount) ||
            $char->weight_percent > 50 ||
            !(grep /^AC_MAKINGARROW$/, @skillsID)){
            goto ARROWCRAFT_END;
        }
#       main::ai_skillUse('AC_MAKINGARROW', 1, 0, 0, $accountID);
        $messageSender->sendArrowCraft($material->{nameID});
        $messageSender->sendArrowCraft($material->{nameID});
        $messageSender->sendArrowCraft($material->{nameID});
        $messageSender->sendArrowCraft($material->{nameID});
        $messageSender->sendArrowCraft($material->{nameID});
#       $messageSender->sendArrowCraft(-1);
ARROWCRAFT_END:
        

        $timeNow1 = time;
    }

    return;

RESPAWN:
    $disabled = 1;
    $char->inventory->getByName("Eden Group Mark")->use;
}

return 1;


