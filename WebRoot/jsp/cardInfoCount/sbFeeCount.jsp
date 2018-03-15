<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">

    var $dg;
    var $grid;
    $(function(){
        $.autoComplete({
            id:"bankId",
            value:"bank_name",
            text:"bank_id",
            table:"base_bank",
            keyColumn:"bank_id",
            minLength:1
        },"bankName");

        $.autoComplete({
            id:"bankName",
            value:"bank_id",
            text:"bank_name",
            table:"base_bank",
            keyColumn:"bank_name",
            minLength:1
        },"bankId");

        $dg = $("#dg");
        $grid = $dg.datagrid({
            url:"cardInfoCount/cardInfoCountAction!querySBFeeCount.action",
            fitColumns:true,
            fit:true,
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            toolbar:"#tb",
            pageList:[100, 200, 500, 1000],
            showFooter:true,
            columns:[[
                {field:'ID',title:'',checkbox:true},
                {field:"APPLY_BATCH_NO",title:"日期",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"BANK_ID",title:"银行编号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"BANK_NAME",title:"银行名称",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"FREE",title:"免费笔数",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"COST",title:"收费笔数",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"TOT_NUM",title:"总笔数",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"TOT_AMT",title:"总金额",sortable:true,width:parseInt($(this).width() * 0.15),formatter:function(value,row,index){
                    if(value == "0"){
                        return "0.00";
                    }else{
                        return $.foramtMoney(Number(value).div100());
                    }
                }},
            ]
            ],
            toolbar:'#tb',
            onLoadSuccess:function(){
                updateFooter();
            },
            onSelect:function(){
                updateFooter();
            },
            onUnselect:function(){
                updateFooter();
            },
            onSelectAll:function(){
                updateFooter();
            },
            onUnselectAll:function(){
                updateFooter();
            }
        });
    });
    function toQueryTask(){
        $dg.datagrid("load",{
            queryType:"0",
            bankId:$("#bankId").val(),
            bankNo:$("#bankNo").val(),
            beginTime:$("#beginTime").val(),
            endTime:$("#endTime").val()
        });
    }


    function updateFooter(){
        var TOTAL_NUM = 0;
        var TOTAL_AMT = 0;
        var FREE = 0;
        var COST = 0;

        var selections = $dg.datagrid("getSelections");
        if(selections && selections.length > 0){
            for(var i in selections){
                var r = selections[i];
                TOTAL_NUM += Number(r.TOT_NUM);
                TOTAL_AMT += Number(r.TOT_AMT);
                FREE += Number(r.FREE);
                COST += Number(r.COST);
            }
        }

        $dg.datagrid("reloadFooter", [{
            isFooter : true,
            APPLY_BATCH_NO : '本页信息统计：',
            TOT_NUM : TOTAL_NUM,
            TOT_AMT : TOTAL_AMT,
            FREE : FREE,
            COST : COST
        }]);
    }


    function toviewtask(){
        var rows = $grid.datagrid("getChecked");
        if(rows && rows.length == 1){
            $.modalDialog({
                title:"任务明细预览",
                fit:true,
                maximized:true,
                closable:false,
                iconCls:"icon-viewInfo",
                href:"jsp/cardInfoCount/sbFeeCountList.jsp?bankId=" + rows[0].BANK_ID + "&applyBatchNo=" + rows[0].APPLY_BATCH_NO,
                tools:[{
                    text:"关闭",iconCls:"icon-cancel",
                    handler:function() {
                        $.modalDialog.handler.dialog("destroy");
                        $.modalDialog.handler = undefined;
                    }
                }]
            });
        }else{
            $.messager.alert("系统消息","请选择一条记录进行预览","warning");
        }
    }

    function exportDetail(){
        var selections = $grid.datagrid("getSelections");
        $('#downloadcsv').attr('src','cardInfoCount/cardInfoCountAction!export.action?queryType=0&rows=20000&' + $("#searchConts").serialize());
    }


</script>
<n:initpage title="省社保工本费统计查询操作！">
    <n:center>
        <div id="tb" >
            <form id="searchConts">
                <table style="width:100%" class="tablegrid">
                    <tr>
                        <td class="tableleft">银行编号：</td>
                        <td class="tableright"><input id="bankId" name="bankId" type="text" class="textinput" maxlength="18"/></td>
                        <td class="tableleft">银行名称：</td>
                        <td class="tableright"><input id="bankName" name="bankName" type="text" class="textinput" maxlength="15"/></td>
                        <td class="tableleft">申领开始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">申领结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                    </tr>
                    <tr>
                        <td class="tableright" colspan="2">
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTask()">查询</a>
                            <shiro:hasPermission name="coCheckViewList">
                                <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" plain="false" onclick="toviewtask();">预览</a>
                            </shiro:hasPermission>
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dg" title="省社保工本费统计"></table>
        <iframe id="downloadcsv" style="display:none"></iframe>
    </n:center>
</n:initpage>