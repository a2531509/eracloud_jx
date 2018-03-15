<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2017/1/5
  Time: 11:23
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 本地卡在异地消费,本地结算拒付汇总-->
<style>
    .datagrid-header-row{
        height:23px;
    }
</style>
<script type="text/javascript">
    var $grid;
    var isExt;
    var QGJFTOTNUM = 0;
    var QGJFTOTAMT = 0;
    var SHJFTOTNUM = 0;
    var SHJFTOTAMT = 0;
    $(function(){
        if("${defaultErrorMsg}" != ""){
            $.messager.alert("系统消息","${defaultErrorMsg}","error");
        }
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
            url:"unionManage/UnionManageAction!queryBdkYdConsumeJfStat.action",
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
            columns:[
                [
                    {field:"V_V",rowspan:2,checkbox:true},
                    {field:"CLR_DATE",rowspan:2,title:"清分日期",sortable:true,align:"center"},
                    {title:"全国",colspan:2,sortable:true},
                    {title:"上海",colspan:2,sortable:true},
                    {title:"总合计",colspan:2,sortable:true}
                ],
                [
                    {field:"QGJFTOTNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGJFTOTAMT",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"SHJFTOTNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"SHJFTOTAMT",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"QGTZTOTAM1",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return (Number(row.QGJFTOTNUM) + Number(row.SHJFTOTNUM));
                    }},
                    {field:"QGTZTOTAM2",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index) {
                        return $.foramtMoney((Number(row.QGJFTOTAMT) + Number(row.SHJFTOTAMT)).toFixed(2));
                    }}
                ]
            ],
            onLoadSuccess:function(data){
                if(dealNull(data["status"]) != 0){
                    $.messager.alert("系统消息",data.errMsg,"warning");
                }
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
        QGJFTOTNUM = 0;
        QGJFTOTAMT = 0;
        SHJFTOTNUM = 0;
        SHJFTOTAMT = 0;

    }
    function calRow(is,data){
        if(is){
            QGJFTOTNUM = Number(QGJFTOTNUM) + (isNaN(data.QGJFTOTNUM) ? 0 : Number(data.QGJFTOTNUM));
            QGJFTOTAMT = parseFloat(QGJFTOTAMT) + (isNaN(data.QGJFTOTAMT) ? 0 : parseFloat(data.QGJFTOTAMT));
            SHJFTOTNUM = Number(SHJFTOTNUM) + (isNaN(data.SHJFTOTNUM) ? 0 : Number(data.SHJFTOTNUM));
            SHJFTOTAMT = parseFloat(SHJFTOTAMT) + (isNaN(data.SHJFTOTAMT) ? 0 : parseFloat(data.SHJFTOTAMT));
        }else{
            QGJFTOTNUM = Number(QGJFTOTNUM) - (isNaN(data.QGJFTOTNUM) ? 0 : Number(data.QGJFTOTNUM));
            QGJFTOTAMT = parseFloat(QGJFTOTAMT) - (isNaN(data.QGJFTOTAMT) ? 0 : parseFloat(data.QGJFTOTAMT));
            SHJFTOTNUM = Number(SHJFTOTNUM) - (isNaN(data.SHJFTOTNUM) ? 0 : Number(data.SHJFTOTNUM));
            SHJFTOTAMT = parseFloat(SHJFTOTAMT) - (isNaN(data.SHJFTOTAMT) ? 0 : parseFloat(data.SHJFTOTAMT));
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {
                "QGJFTOTNUM": QGJFTOTNUM,
                "QGJFTOTAMT": parseFloat(QGJFTOTAMT).toFixed(2),
                "SHJFTOTNUM": SHJFTOTNUM,
                "SHJFTOTAMT": parseFloat(SHJFTOTAMT).toFixed(2)
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
        commonDwr.isDownloadComplete("queryBdkYdConsumeJfStatExport",function(data){
            if(data["returnValue"] == '0'){
                clearInterval(isExt);
                jAlert("导出成功！","info",function(){
                    $.messager.progress("close");
                });
            }
        });
    }
    function exportFile(){
        if(dealNull($("#beginTime").val()) == ""){
            jAlert("请输入导出起始日期！",function(){
                $("#beginTime").focus();
            });
            return;
        }
        if(dealNull($("#beginTime").val()) == ""){
            jAlert("请输入导出结束日期！",function(){
                $("#beginTime").focus();
            });
            return;
        }
        if($("#beginTime").val() > $("#beginTime").val()){
            jAlert("起始日期不能大于结束日期！");
            return;
        }
        jConfirm("您确定要进行导出吗？",function(){
            $.messager.progress({text:"正在进行导出,请稍候..."});
            $("#searchConts").get(0).action = "unionManage/UnionManageAction!queryBdkYdConsumeJfStatExport.action";
            $("#searchConts").get(0).submit();
            startCycle();
        });
    }
</script>
<n:initpage title="互联互通本地卡在异地消费拒付数据进行统计！<span style='color:red'>注意：</span>此拒付数据是本地卡在异地消费后，互联互通将数据传回本地，本地结算时拒付的数据！">
    <n:center>
        <div id="tb">
            <form id="searchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft">清分起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" value="${beginTime}" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">清分结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" value="${endTime}" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableright" colspan="1" style="padding-left: 20px">
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

