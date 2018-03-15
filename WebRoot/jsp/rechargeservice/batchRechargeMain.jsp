<%--
  Created by IntelliJ IDEA.
  User: yangning
  Date: 2017-09-14
  Time: 10:28
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
    var $grid;
    var totNum = 0,totAmt = 0,useableNum = 0,useableAmt = 0,sucNum = 0,sucAmt = 0;
    $(function(){
        initCal();
        createSysBranch(
            {id:"brchId"},
            {id:"userId"}
        );
        createLocalDataSelect({
            id:"state",
            data:[
                {value:"",text:"请选择"},
                {value:"0",text:"初始导入"},
                //{value:"1",text:"审核失败"},
                //{value:"2",text:"审核成功"},
                {value:"3",text:"部分充值"},
				{value:"4",text:"充值完成"}
            ]
        });
        $grid = createDataGrid({
            id:"dg",
            url:"recharge/rechargeAction!toQueryBatchRechargeImportData.action",
            border:false,
            fit:true,
            pagination:true,
            pageSize:20,
            rownumbers:true,
            striped:true,
            scrollbarSize:0,
            singleSelect:false,
            fitColumns:true,
            columns:[[
                {field:"",checkbox:true},
                {field:"DATA_SEQ",title:"流水号",sortable:true, width:parseInt($(this).width() * 0.06)},
                {field:"ACCKIND",title:"账户类型",sortable:true, width:parseInt($(this).width() * 0.06)},
                {field:"TOT_NUM",title:"总笔数",sortable:true,width:parseInt($(this).width() * 0.05)},
                {field:"TOT_AMT",title:"总金额",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"USEABLE_NUM",title:"可充值笔数",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"USEABLE_AMT",title:"可充值金额",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"SUC_NUM",title:"成功充值笔数",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"SUC_AMT",title:"成功充值金额",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"STATESTR",title:"状态",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"FULLNAME",title:"导入网点",sortable:true, width:parseInt($(this).width() * 0.15)},
                {field:"USERNAME",title:"导入柜员",sortable:true},
                {field:"IMPDATE",title:"导入时间",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"NOTE",title:"备注",sortable:true}
            ]],
            onLoadSuccess:function(data){
                if(data.status != 0){
                    $.messager.alert("系统消息",data.errMsg,"error");
                    return;
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
                for(var i=0,hk=rows.length;i < hk;i++){
                    var data  = rows[i];
                    calRow(true,data);
                }
                updateFooter();
            },
            onUncheckAll:function(rows){
                initCal();
                updateFooter();
            }
        })
    });
    function query(){
        var params =
            {
                "rec.dealNo":$("#dealNo").val(),
                "rec.brchId":$("#brchId").combotree("getValue"),
                "rec.userId":$("#userId").combobox("getValue"),
                "beginTime":$("#startDate").val(),
                "endTime":$("#endDate").val(),
                "queryType":"0",
                "rec.dealState":$("#state").combobox("getValue")
            };
        $grid.datagrid("load",params);
    }
    function initCal(){
        totNum = 0,totAmt = 0,useableNum = 0,useableAmt = 0,sucNum = 0,sucAmt = 0;
    }
    function calRow(is,data){
        if(is){
            totNum = parseFloat(totNum) + parseFloat(data.TOT_NUM);
            totAmt = parseFloat(totAmt) + parseFloat(data.TOT_AMT);
            useableNum = parseFloat(useableNum) + parseFloat(data.USEABLE_NUM);
            useableAmt = parseFloat(useableAmt) + parseFloat(data.USEABLE_AMT);
            sucNum = parseFloat(sucNum) + parseFloat(data.SUC_NUM);
            sucAmt = parseFloat(sucAmt) + parseFloat(data.SUC_AMT);
        }else{
            totNum = parseFloat(totNum) - parseFloat(data.TOT_NUM);
            totAmt = parseFloat(totAmt) - parseFloat(data.TOT_AMT);
            useableNum = parseFloat(useableNum) - parseFloat(data.USEABLE_NUM);
            useableAmt = parseFloat(useableAmt) - parseFloat(data.USEABLE_AMT);
            sucNum = parseFloat(sucNum) - parseFloat(data.SUC_NUM);
            sucAmt = parseFloat(sucAmt) - parseFloat(data.SUC_AMT);
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {
                "ACCKIND":"本页信息统计:",
				"TOT_NUM":totNum,
				"TOT_AMT":totAmt,
				"USEABLE_NUM":useableNum,
				"USEABLE_AMT":useableAmt,
				"SUC_NUM":sucNum,
				"SUC_AMT":sucAmt,
            }
        ]);
    }
    function openimportwin(){
        $.modalDialog({
            title:"批量充值导入",
            iconCls:"icon-import",
            fit:false,
            maximized:false,
            shadow:false,
            closable:false,
            maximizable:false,
            width:700,
            height:250,
            href:"jsp/rechargeservice/batchRechargeAdd.jsp",
            tools:[{
                iconCls:"icon_cancel_01",
                handler:function(){
                    $.modalDialog.handler.dialog("destroy");
                    $.modalDialog.handler = undefined;
                }
            }],
            buttons:[
                {
                    text:"关闭",
                    iconCls:"icon-cancel",
                    handler:function(){
                        $.modalDialog.handler.dialog("destroy");
                        $.modalDialog.handler = undefined;
                    }
                }
            ]
        });
    }
    function saveImportData(){
        if($("#importFile").val() == ""){
            jAlert("请选择将要进行导入的文件！","warning");
            return;
        }
        var impAccKind = $("#impAccKind").combobox("getValue");
        if (dealNull(impAccKind) == ""){
			jAlert("请选择充值账户类型！","error",function(){
                $("#impAccKind").combobox("showPanel");
            });
			return;
		}
		var isAudit = "1";
        $.messager.confirm("系统消息","您确认要导入选定的人员数据文件吗？",function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                commonDwr.uploadBatchRechargeDataFile(dwr.util.getValue("importFile"), "",impAccKind,isAudit,function(data){
                    $.messager.progress("close");
                    if(!data){
                        jAlert("导入数据出现错误,系统未返回处理结果！");
                    }else if(data.status != '0'){
                        jAlert(data.errMsg);
                    }else {
                        jAlert("导入成功！","info",function(){
                            $.modalDialog.handler.dialog("destroy");
                            $.modalDialog.handler = undefined;
                        });
                        $grid.datagrid("reload");
                    }
                });
            }
        });
    }
    function toviewdata() {
        var rows = $grid.datagrid("getChecked");
        if(rows.length != 1){
            $.messager.alert("系统消息", "请选择一条要预览的记录！", "warning");
            return;
        }
        var dealNo = rows[0].DATA_SEQ;
        $.modalDialog({
            title:"预览",
            fit:true,
            iconCls:"icon-viewInfo",
            maximized:true,
            maximizable:false,
            closable:false,
            href:"jsp/rechargeservice/batchRechargeView.jsp?dealNo=" + dealNo,
            tools:[{
                iconCls:"icon_cancel_01",
                handler:function(){
                    $.modalDialog.handler.dialog("destroy");
                    $.modalDialog.handler = undefined;
                }
            }]
        });
    }
    function deletedata(){
        var rows = $grid.datagrid("getChecked");
        if (rows.length != 1) {
            $.messager.alert("系统消息", "请选择一条记录进行删除！", "warning");
            return;
        }
        $.messager.confirm("系统消息","您确定要删除勾选的记录信息吗？",function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                $.post("recharge/rechargeAction!saveBatchRechargeStateChanged.action",{"dealNo":rows[0].DATA_SEQ,"queryType":"0"},function(data,status){
                    $.messager.progress("close");
                    if(status == "success"){
                        if(dealNull(data.status) == "0"){
                            jAlert("删除成功！","info",function(){
                                $grid.datagrid("reload");
                            });
                        }else{
                            jAlert(dealNull(data.errMsg));
                        }
                    }else{
                        jAlert("请求出现错误，请重新进行操作！");
                    }
                },"json");
            }
        })
    }
    function tobatchrecharge(){
        var rows = $grid.datagrid("getChecked");
        if (rows.length != 1) {
            $.messager.alert("系统消息","请勾选一saveBatchRecharge条记录进行充值！","warning");
            return;
        }
        var tempTitle = "您确定要充值勾选的记录信息吗？";
        $.messager.confirm("系统消息",tempTitle,function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                $.post("recharge/rechargeAction!.action",{"dealNo":rows[0].DATA_SEQ},function(data,status){
                    $.messager.progress("close");
                    if(status == "success"){
                        var tmpCount = data.count;
                        if(dealNull(data.status) == "0"){
                            if(dealNull(tmpCount) == 0){
                                jAlert("充值失败！","error",function(){
                                    $grid.datagrid("reload");
                                });
                            }else{
                                jAlert("充值成功！","info",function(){
                                    $grid.datagrid("reload");
                                });
							}
                        }else{
                            jAlert(dealNull(data.errMsg));
                        }
                    }else{
                        jAlert("请求出现错误，请重新进行操作！");
                    }
                },"json");
            }
        })
    }
</script>
<n:initpage title="未登账户进行批量充值操作！">
	<n:center>
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">流水号：</td>
					<td class="tableright"><input id="dealNo" class="textinput" maxlength="10"></td>
					<td class="tableleft">网点：</td>
					<td class="tableright"><input id="brchId" class="textinput"></td>
					<td class="tableleft">柜员：</td>
					<td class="tableright"><input id="userId" class="textinput"></td>
					<td class="tableleft">充值状态：</td>
					<td class="tableright"><input id="state" class="textinput" type="text"></td>
				</tr>
				<tr>
					<td class="tableleft">起始时间：</td>
					<td class="tableright"><input id="startDate" class="textinput Wdate" onclick="WdatePicker({dataFormat:'yyyy-MM-dd', readOnly:true, maxDate:'#F{$dp.$D(\'endDate\') || \'%y-%M-%d\'}'})"></td>
					<td class="tableleft">结束时间：</td>
					<td class="tableright"><input id="endDate" class="textinput Wdate" onclick="WdatePicker({dataFormat:'yyyy-MM-dd', readOnly:true, minDate:'#F{$dp.$D(\'startDate\')}', maxDate:'%y-%M-%d'})"></td>
					<td class="tableleft">&nbsp;</td>
					<td class="tableleft">&nbsp;</td>
					<td class="tableright" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" onclick="openimportwin()">导入</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" onclick="toviewdata()">预览</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" onclick="deletedata()">删除</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" onclick="tobatchrecharge()">充值</a>
						<%--<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" onclick="exportdata()">导出</a>--%>
						<%--<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" onclick="exportdata()">审核</a>--%>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="充值记录信息"></table>
	</n:center>
</n:initpage>
