<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
    var $dgview;
    var $tempview;
    var $gridview;
    var checkId;
    $(function(){
        //结算状态
        $("#refuseReason").combobox({
            width:174,
            valueField:"value",
            textField:"text",
            panelHeight:"auto",
            editable:false,
            data:[
                {value:"", text:"请选择"},
                {value:"00", text:"发卡方调整"},
                {value:"01", text:"TAC错误"},
                {value:"02", text:"非法记录"},
                {value:"03", text:"重复记录"},
                {value:"04", text:"灰记录"},
                {value:"05", text:"账户余额不足"},
                {value:"06", text:"测试数据"},
                {value:"07", text:"交易时间格式不正确"},
                {value:"09", text:"调整拒付"},
                {value:"10", text:"正常付款"}
            ]
        });
        $("#processingState").combobox({
			textField:"text",
			valueField:"value",
			panelHeight:"auto",
			editable:false,
			data:[
				{value:"0", text:"待处理"},
				{value:"1", text:"已处理"}
			]
		});

        $dgview = $("#dgview");
        $gridview=$dgview.datagrid({
            url:"clrDeal/clrDealAction!findAllOfflineMxList.action",
            pagination:true,
            rownumbers:true,
            border:true,
            striped:true,
            fit:true,
            singleSelect:false,
            fitColumns:true,
            pageSize:20,
            columns:[[
                {field:'ID',checkbox:true},
                {field:'ACPT_ID',title:'商户编号',sortable:true,width:parseInt($(this).width()*0.08)},
                {field:'MERCHANT_NAME',title:'商户名称',sortable:true,width:parseInt($(this).width()*0.12)},
                {field:'END_ID',title:'终端号',sortable:true,width:parseInt($(this).width()*0.05)},
                {field:'END_DEAL_NO',title:'终端流水号',sortable:true,width:parseInt($(this).width()*0.06)},
                {field:'DEAL_DATE',title:'交易时间',sortable:true,width:parseInt($(this).width()*0.08)},
                {field:'DEAL_AMT',title:'交易金额',sortable:true,width:parseInt($(this).width()*0.04)},
                {field:'REFUSE_REASON',title:'数据状态',sortable:true,width:parseInt($(this).width()*0.05),formatter:function(value,row){
                    if("正常付款"==row.REFUSE_REASON){
                        return "<font color=green>"+row.REFUSE_REASON+"<font>";
                    }else if("发卡方调整"== row.REFUSE_REASON){
                        return "<font color=deepskyblue>"+row.REFUSE_REASON+"<font>";
                    }else{
                        return "<font color=red>"+row.REFUSE_REASON+"<font>";
                    }

                }},
               {field:'PROCESSING_STATE',title:'处理状态',sortable:true,width:parseInt($(this).width()*0.05),formatter:function(value,row){
                    if(row.PROCESSING_STATE == "0"){
                        return "<span style='color:orange'>待处理</span>";
                    }else if(row.PROCESSING_STATE == "1"){
                        return "<span style='color:green'>已处理</span>";
                    }

                }},
                {field:'DEAL_BATCH_NO',title:'交易日',sortable:true,width:parseInt($(this).width()*0.05)},
                {field:'CLR_DATE',title:'记账日期',sortable:true,width:parseInt($(this).width()*0.06)},
                {field:'SEND_FILE_NAME',title:'上传文件名',sortable:true,width:parseInt($(this).width()*0.15)}
            ]],toolbar:'#tbview',
            onLoadSuccess:function(data){
                $("#dgview").datagrid("resize");
                $("input[type=checkbox]").each(function(){
                    this.checked = false;
                });
                if(data.status != 0){
                    $.messager.alert('系统消息',data.errMsg,'error');
                }
            }
        });


    });

    //预览明细方法
    function viewOffineListByID(checkSignId){
        checkId = checkSignId;
        $dgview.datagrid("load",{
            queryType:"0",
            checkSignId:checkSignId,
            "pof.endId":$("#endId").val(),
            "pof.dealBatchNo":$("#dealBatchNo").val(),
            "pof.endDealNo":$("#endDealNo").val(),
            "pof.cardNo":$("#cardNo").val(),
            "pof.refuseReason":$("#refuseReason").combobox("getValue"),
            "pof.processingState":$("#processingState").combobox("getValue")
        });
    }

    //查询页面方法
    function queryCheckList(){
        $dgview.datagrid("load",{
            queryType:"0",
            checkSignId:checkId,
            "pof.endId":$("#endId").val(),
            "pof.dealBatchNo":$("#dealBatchNo").val(),
            "pof.endDealNo":$("#endDealNo").val(),
            "pof.cardNo":$("#cardNo").val(),
            "pof.refuseReason":$("#refuseReason").combobox("getValue"),
            "pof.processingState":$("#processingState").combobox("getValue")
        });
    }


    //脱机数据处理
    function offlineDeal(){
        var row = $dgview.datagrid('getSelections');
        var reqData = "";
        for(var i in row){
            reqData+= row[i].ID + ",";
        }
        if(row){
            $.messager.confirm('系统消息','您确定要调整数据吗？',function(is){
                if(is){
                    $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
                    $.ajax({
                        //timeout:30000,
                        type:"POST",
                        dataType:"json",
                        url:"clrDeal/clrDealAction!offlineDeal.action",
                        data:{reqData:JSON.stringify(reqData)},
                        error:function(jqXHR, textStatus, errorThrown){
                            if(textStatus=="timeout"){
                                $.messager.progress('close');
                                $dgview.datagrid("reload");
                                $.messager.alert("系统错误","系统处理超时，请重试！","error");
                            }else{
                                $.messager.progress('close');
                                $dgview.datagrid("reload");
                                $.messager.alert("系统错误",textStatus,"error");
                            }
                        },
                        success:function(data){
                            $.messager.progress('close');
                            $dgview.datagrid("reload");
                            if(data.status == '0'){
                                $.messager.alert("提示信息","脱机数据入账成功","info");
                            }else{
                                $.messager.alert("系统错误",data.errMsg,"error");
                            }
                        }
                    });
				}
            });
        }else{
            $.messager.alert("系统消息","请选择一条记录信息进行平账！","error");
        }
    }
    function backCancel(){
        $.modalDialog.handler.dialog('destroy');
        $.modalDialog.handler = undefined;
    }
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tbview" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">终端号：</td>
					<td class="tableright" style="width:20%"><input type="text" name="pof.endId" id="endId" class="textinput"/></td>
					<td class="tableleft" style="width:8%">批次号：</td>
					<td class="tableright" style="width:20%"><input type="text" name="pof.dealBatchNo" id="dealBatchNo" class="textinput"/></td>
					<td class="tableleft" style="width:8%">终端流水：</td>
					<td class="tableright" style="width:20%"><input type="text" name="pof.endDealNo" id="endDealNo"  class="textinput"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input type="text" name="pof.cardNo" id="cardNo"  class="textinput" /></td>
					<td class="tableleft">数据状态：</td>
					<td class="tableright"><input type="text" name="pof.refuseReason" id="refuseReason"  class="easyui-combobox" /></td>
					<td class="tableleft">处理状态：</td>
					<td class="tableright"><input type="text" name="pof.processingState" id="processingState"  class="easyui-combobox" /></td>
					<td class="tableleft" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="queryCheckList();">查询</a>
						<shiro:hasPermission name="offlineDeal">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back" plain="false" onclick="offlineDeal();">调整为可付</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dgview"></table>
	</div>
</div>
