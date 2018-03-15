<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2016/12/29
  Time: 15:14
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 异地卡本地消费汇总-->
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
    var qgjftotnum = 0;
    var qgjftotamt = 0;
    var qgtztotnum = 0;
    var qgtztotamt = 0;
    var shzctotnum = 0;
    var shzctotamt = 0;
    var shjftotnum = 0;
    var shjftotamt = 0;
    var shtztotnum = 0;
    var shtztotamt = 0;
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
            url:"unionManage/UnionManageAction!queryYdkBdConsumeStat.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:false,
            fit:true,
            singleSelect:false,
            pageList:[100, 200, 500, 1000, 2000],
            scrollbarSize:0,
            autoRowHeight:true,
            view:myview,
            frozenColumns:[
                [
                    {field:"V_V",rowspan:3,checkbox:true},
                    {field:"SETTLE_DATE",rowspan:3,title:"结算日期",sortable:true,align:"center"},
                    {title:"全国",colspan:8,sortable:true}
                ],
                [
                    {title:"结算数据",colspan:6,sortable:true},
                    {title:"小计",colspan:2,sortable:true}
                ],
                [
                    {field:"QGZCTOTNUM",title:"正常笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGZCTOTAMT",title:"正常金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"QGJFTOTNUM",title:"拒付笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGJFTOTAMT",title:"拒付金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"QGTZTOTNUM",title:"调整笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"QGTZTOTAMT",title:"调整金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"QGTZTOTAM1",title:"结算笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return (Number(row.QGZCTOTNUM) + Number(row.QGTZTOTNUM));
                    }},
                    {field:"QGTZTOTAM2",title:"结算金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index) {
                        return $.foramtMoney((Number(row.QGZCTOTAMT) + Number(row.QGTZTOTAMT)).toFixed(2));
                    }}
                ]
            ],
            columns:[
                [
                    {title:"上海",colspan:8,sortable:true},
                    {title:"总合计",colspan:2,rowspan:2,sortable:true}
                ],
                [
                    {title:"结算数据",colspan:6,sortable:true},
                    {title:"小计",colspan:2,sortable:true}
                ],
                [
                    {field:"SHZCTOTNUM",title:"正常笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"SHZCTOTAMT",title:"正常金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"SHJFTOTNUM",title:"拒付笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"SHJFTOTAMT",title:"拒付金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"SHTZTOTNUM",title:"调整笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05)},
                    {field:"SHTZTOTAMT",title:"调整金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return $.foramtMoney(value);
                    }},
                    {field:"SHTZTOTAM1",title:"结算笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
                        return (Number(row.SHZCTOTNUM) + Number(row.SHTZTOTNUM));
                    }},
                    {field:"SHTZTOTAM2",title:"结算金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index) {
                        return $.foramtMoney((Number(row.SHZCTOTAMT) + Number(row.SHTZTOTAMT)).toFixed(2));
                    }},
                    {field:"SHTZTOTAM3",title:"总结算笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
                        return (Number(row.QGZCTOTNUM) + Number(row.QGTZTOTNUM) + Number(row.SHZCTOTNUM) + Number(row.SHTZTOTNUM));
                    }},
                    {field:"SHTZTOTAM4",title:"总结算金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index) {
                        return $.foramtMoney((Number(row.QGZCTOTAMT) + Number(row.QGTZTOTAMT) + Number(row.SHZCTOTAMT) + Number(row.SHTZTOTAMT)).toFixed(2));
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
        qgzctotnum = 0;
        qgzctotamt = 0;
        qgjftotnum = 0;
        qgjftotamt = 0;
        qgtztotnum = 0;
        qgtztotamt = 0;
        shzctotnum = 0;
        shzctotamt = 0;
        shjftotnum = 0;
        shjftotamt = 0;
        shtztotnum = 0;
        shtztotamt = 0;
    }
    function calRow(is,data){
        if(is){
            qgzctotnum = Number(qgzctotnum) + (isNaN(data.QGZCTOTNUM) ? 0 : Number(data.QGZCTOTNUM));
            qgzctotamt = parseFloat(qgzctotamt) + (isNaN(data.QGZCTOTAMT) ? 0 : parseFloat(data.QGZCTOTAMT));
            qgjftotnum = Number(qgjftotnum) + (isNaN(data.QGJFTOTNUM) ? 0 : Number(data.QGJFTOTNUM));
            qgjftotamt = parseFloat(qgjftotamt) + (isNaN(data.QGJFTOTAMT) ? 0 : parseFloat(data.QGJFTOTAMT));
            qgtztotnum = Number(qgtztotnum) + (isNaN(data.QGTZTOTNUM) ? 0 : Number(data.QGTZTOTNUM));
            qgtztotamt = parseFloat(qgtztotamt) + (isNaN(data.QGTZTOTAMT) ? 0 : parseFloat(data.QGTZTOTAMT));
            shzctotnum = Number(shzctotnum) + (isNaN(data.SHZCTOTNUM) ? 0 : Number(data.SHZCTOTNUM));
            shzctotamt = parseFloat(shzctotamt) + (isNaN(data.SHZCTOTAMT) ? 0 : parseFloat(data.SHZCTOTAMT));
            shjftotnum = Number(shjftotnum) + (isNaN(data.SHJFTOTNUM) ? 0 : Number(data.SHJFTOTNUM));
            shjftotamt = parseFloat(shjftotamt) + (isNaN(data.SHJFTOTAMT) ? 0 : parseFloat(data.SHJFTOTAMT));
            shtztotnum = Number(shtztotnum) + (isNaN(data.SHTZTOTNUM) ? 0 : Number(data.SHTZTOTNUM));
            shtztotamt = parseFloat(shtztotamt) + (isNaN(data.SHTZTOTAMT) ? 0 : parseFloat(data.SHTZTOTAMT));
        }else{
            qgzctotnum = Number(qgzctotnum) - (isNaN(data.QGZCTOTNUM) ? 0 : Number(data.QGZCTOTNUM));
            qgzctotamt = parseFloat(qgzctotamt) - (isNaN(data.QGZCTOTAMT) ? 0 : parseFloat(data.QGZCTOTAMT));
            qgjftotnum = Number(qgjftotnum) - (isNaN(data.QGJFTOTNUM) ? 0 : Number(data.QGJFTOTNUM));
            qgjftotamt = parseFloat(qgjftotamt) - (isNaN(data.QGJFTOTAMT) ? 0 : parseFloat(data.QGJFTOTAMT));
            qgtztotnum = Number(qgtztotnum) - (isNaN(data.QGTZTOTNUM) ? 0 : Number(data.QGTZTOTNUM));
            qgtztotamt = parseFloat(qgtztotamt) - (isNaN(data.QGTZTOTAMT) ? 0 : parseFloat(data.QGTZTOTAMT));
            shzctotnum = Number(shzctotnum) - (isNaN(data.SHZCTOTNUM) ? 0 : Number(data.SHZCTOTNUM));
            shzctotamt = parseFloat(shzctotamt) - (isNaN(data.SHZCTOTAMT) ? 0 : parseFloat(data.SHZCTOTAMT));
            shjftotnum = Number(shjftotnum) - (isNaN(data.SHJFTOTNUM) ? 0 : Number(data.SHJFTOTNUM));
            shjftotamt = parseFloat(shjftotamt) - (isNaN(data.SHJFTOTAMT) ? 0 : parseFloat(data.SHJFTOTAMT));
            shtztotnum = Number(shtztotnum) - (isNaN(data.SHTZTOTNUM) ? 0 : Number(data.SHTZTOTNUM));
            shtztotamt = parseFloat(shtztotamt) - (isNaN(data.SHTZTOTAMT) ? 0 : parseFloat(data.SHTZTOTAMT));
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {
                "SETTLE_DATE":"合计",
                "QGZCTOTNUM": qgzctotnum,
                "QGZCTOTAMT": parseFloat(qgzctotamt).toFixed(2),
                "QGJFTOTNUM": qgjftotnum,
                "QGJFTOTAMT": parseFloat(qgjftotamt).toFixed(2),
                "QGTZTOTNUM": qgtztotnum,
                "QGTZTOTAMT": parseFloat(qgtztotamt).toFixed(2),
                "SHZCTOTNUM": shzctotnum,
                "SHZCTOTAMT": parseFloat(shzctotamt).toFixed(2),
                "SHJFTOTNUM": shjftotnum,
                "SHJFTOTAMT": parseFloat(shjftotamt).toFixed(2),
                "SHTZTOTNUM": shtztotnum,
                "SHTZTOTAMT": parseFloat(shtztotamt).toFixed(2)
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
        commonDwr.isDownloadComplete("queryYdkBdConsumeStatExport",function(data){
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
            $("#searchConts").get(0).action = "unionManage/UnionManageAction!queryYdkBdConsumeStatExport.action";
            $("#searchConts").get(0).submit();
            startCycle();
        });
    }
</script>
<n:initpage title="互联互通异地卡在本地消费进行结算统计！">
    <n:center>
        <div id="tb">
            <form id="searchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft">起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" value="${beginTime}" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">结束日期：</td>
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
