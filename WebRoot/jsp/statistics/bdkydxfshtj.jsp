<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2016/12/29
  Time: 15:14
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 本地卡在异地消费发卡机构汇总-->
<style>
    .datagrid-header-row{
        height:23px;
    }
</style>
<script type="text/javascript">
    var $grid;
    var isExt;
    var qgzctotnum = 0;
    var qgzctotamt = 0;
    var shzctotnum = 0;
    var shzctotamt = 0;
    $(function(){
        if("${defaultErrorMsg}" != ""){
            $.messager.alert("系统消息","${defaultErrorMsg}","error");
        }
        createCustomSelect({
            id:"bizId",
            value:"card_org_id",
            text:"card_org_name",
            table:"card_org_bind_section",
            where:"state = '0' group by card_org_id,card_org_name ",
            orderby:"card_org_id asc",
            from:1,
            to:200
        });
        var myview = $.extend({}, $.fn.datagrid.defaults.view, {
            renderFooter: function(target, container, frozen){
                var opts = $.data(target, 'datagrid').options;
                var rows = $.data(target, 'datagrid').footer || [];
                var fields = $(target).datagrid('getColumnFields', frozen);
                var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
                for(var i=0; i<rows.length; i++){
                    var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
                    var style = styleValue ? 'style="' + styleValue + '"' : '';
                    table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
                    table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
                    table.push('</tr>');
                }
                table.push('</tbody></table>');
                $(container).html(table.join(''));
            }
        });
        $grid = createDataGrid({
            id:"dg",
            url:"unionManage/UnionManageAction!queryBdkYdConsumeShStat.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:true,
            fit:true,
            singleSelect:false,
            pageList:[100, 200, 500, 1000, 2000],
            scrollbarSize:0,
            autoRowHeight:true,
            view:myview,
            multiSort:true,
            columns:[
                [
                    {field:"V_V",rowspan:2,checkbox:true},
                    {field:"SETTLE_DATE",rowspan:2,title:"结算日期",sortable:true,align:"center"},
                    {field:"CLR_DATE",rowspan:2,title:"清分日期",sortable:true,align:"center"},
                    {title:"发卡机构",colspan:2,sortable:true},
                    {title:"全国",colspan:2,sortable:true},
                    {title:"上海",colspan:2,sortable:true},
                    {title:"总合计",colspan:2,sortable:true}
                ],
                [
                    {field:"CARD_ORG_ID",title:"机构代码",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"CARD_ORG_NAME",title:"机构名称",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGZCTOTNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGZCTOTAMT",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"SHZCTOTNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"SHZCTOTAMT",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"QGTZTOTAM1",title:"笔数",align:"center",sortable:false,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return (Number(row.QGZCTOTNUM) + Number(row.SHZCTOTNUM));
                    }},
                    {field:"QGTZTOTAM2",title:"金额",align:"center",sortable:false,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index) {
                        return $.foramtMoney((Number(row.QGZCTOTAMT) + Number(row.SHZCTOTAMT)).toFixed(2));
                    }}
                ]
            ],
            onLoadSuccess:function(data){
                if(dealNull(data["status"]) != 0){
                    $.messager.alert("系统消息",data.errMsg,"warning");
                }
                $grid.datagrid("autoMergeCells",["CARD_ORG_ID","CARD_ORG_NAME","SETTLE_DATE","CLR_DATE"]);
                initCal();
                updateFooter();
            },
            onCheck:function(index,data){
                calRow(true,data);
                updateFooter();
            },
            onUncheck:function(index,data){
                calRow(false,data);
                updateFooter();
            },
            onCheckAll:function(rows){
                initCal();
                for(var i = 0,hk = rows.length;i < hk;i++){
                    var data  = rows[i];
                    calRow(true,data);
                }
                updateFooter();
            },
            onUncheckAll:function(rows){
                initCal();
                updateFooter();
            }
        });
    });
    function initCal(){
        qgzctotnum = 0;
        qgzctotamt = 0;
        shzctotnum = 0;
        shzctotamt = 0;

    }
    function calRow(is,data){
        if(is){
            qgzctotnum = Number(qgzctotnum) + (isNaN(data.QGZCTOTNUM) ? 0 : Number(data.QGZCTOTNUM));
            qgzctotamt = parseFloat(qgzctotamt) + (isNaN(data.QGZCTOTAMT) ? 0 : parseFloat(data.QGZCTOTAMT));
            shzctotnum = Number(shzctotnum) + (isNaN(data.SHZCTOTNUM) ? 0 : Number(data.SHZCTOTNUM));
            shzctotamt = parseFloat(shzctotamt) + (isNaN(data.SHZCTOTAMT) ? 0 : parseFloat(data.SHZCTOTAMT));
        }else{
            qgzctotnum = Number(qgzctotnum) - (isNaN(data.QGZCTOTNUM) ? 0 : Number(data.QGZCTOTNUM));
            qgzctotamt = parseFloat(qgzctotamt) - (isNaN(data.QGZCTOTAMT) ? 0 : parseFloat(data.QGZCTOTAMT));
            shzctotnum = Number(shzctotnum) - (isNaN(data.SHZCTOTNUM) ? 0 : Number(data.SHZCTOTNUM));
            shzctotamt = parseFloat(shzctotamt) - (isNaN(data.SHZCTOTAMT) ? 0 : parseFloat(data.SHZCTOTAMT));
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {
                "QGZCTOTNUM": qgzctotnum,
                "QGZCTOTAMT": parseFloat(qgzctotamt).toFixed(2),
                "SHZCTOTNUM": shzctotnum,
                "SHZCTOTAMT": parseFloat(shzctotamt).toFixed(2)
            }
        ]);
    }
    function query(){
        if($("#beginTime").val() != "" && $("#endTime").val() != ""){
            if($("#beginTime").val() > $("#endTime").val()){
                jAlert("起始日期不能大于结束日期！");
                return;
            }
        }
        var params = getformdata("searchConts");
        params["queryType"] = "0";
        $grid.datagrid("load",params);
    }
    function startCycle(){
        isExt = setInterval("startDetect()",800);
    }
    function startDetect(){
        commonDwr.isDownloadComplete("queryBdkYdConsumeShStatExport",function(data){
            if(data["returnValue"] == '0'){
                clearInterval(isExt);
                jAlert("导出成功！","info",function(){
                    $.messager.progress("close");
                });
            }
        });
    }
    function exportFile(){
        jConfirm("您确定要进行导出吗？",function(){
            $.messager.progress({text:"正在进行导出,请稍候..."});
            $("#searchConts").get(0).action = "unionManage/UnionManageAction!queryBdkYdConsumeShStatExport.action";
            $("#searchConts").get(0).submit();
            startCycle();
        });
    }
</script>
<n:initpage title="互联互通本地各发卡机构卡在异地消费进行结算统计！">
    <n:center>
        <div id="tb">
            <form id="searchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft">发卡机构：</td>
                        <td class="tableright"><input id="bizId" name="bizId" type="text" class="textinput"/></td>
                        <td class="tableleft">结算起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">结算结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                    </tr>
                    <tr>
                        <td class="tableleft">清分起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="clrBeginTime" value="${clrBeginTime}" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">清分结束日期：</td>
                        <td class="tableright"><input id="endTime" name="clrEndTime" value="${clrEndTime}" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableright" colspan="2" style="text-align: center">
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportFile()">导出</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dg" title="汇总信息" style="width:100%"></table>
    </n:center>
</n:initpage>
