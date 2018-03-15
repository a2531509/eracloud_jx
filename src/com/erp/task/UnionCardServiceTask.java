package com.erp.task;

import com.erp.service.UnionCardService;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

/**
 * @desc 互联互通相关定时任务
 * @author yangn
 * @date 2016-09-18
 * @Msg 互联互通相关定时任务
 */
@Component("unionCardServiceTask")
public class UnionCardServiceTask{
    private Logger logger = Logger.getLogger(UnionCardServiceTask.class);
    @Resource(name = "unionCardService")
    private UnionCardService unionCardService;
    public void execute(){
        try{
            //unionCardService.saveUploadUnionCardFh("",true,null);
            unionCardService.saveDownLoadUnionCardFile();
        }catch(Exception e){
            //logger.error(e);
        }
    }
    public UnionCardService getUnionCardService(){
        return unionCardService;
    }
    public void setUnionCardService(UnionCardService unionCardService){
        this.unionCardService = unionCardService;
    }
}
