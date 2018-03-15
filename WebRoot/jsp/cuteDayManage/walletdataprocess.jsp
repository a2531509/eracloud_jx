<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$grid = createDataGrid({
			id:"dg",
			url:"adjustSysAccAction/adjustSysAccAction!queryWalletInfo.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			fitColumns: true,
			scrollbarSize:0,
			autoRowHeight:true,
			columns:[[   
			    {field:"SETTLEID",title:"id",sortable:true,checkbox:"ture"},
				{field:"ACPT_ID",title:"受理点编号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"END_ID",title:"终端号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"DEAL_NO",title:"流水号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"ACC_BAL",title:"交易前金额",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"DEAL_DATE",title:"交易时间",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"REFUSE_REASON",title:"拒付原因",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"CLR_DATE",title:"清分日期",sortable:true,width : parseInt($(this).width() * 0.05)}
			]]
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_SMZK%>",
			//isShowDefaultOption:false
		});
	});
	
	function query(){
		var data = getformdata("searchConts");
		data["queryType"] = "0";
		$grid.datagrid("load",data);
	}
	function walletProcess(){
		var rows = $grid.datagrid("getChecked");
		if(rows.length != 1){
			$.messager.alert("系统消息","请选择一条记录进行处理","error");
			return;
		}
			var selectId = rows[0].SETTLEID;
			$.messager.confirm("系统消息","您确定要处理选择的记录吗？",function(r){
				if(r){
					$.messager.progress({text:"正在处理,请稍后...."});
					$.post("adjustSysAccAction/adjustSysAccAction!processWalletInfo.action",{selectId:selectId},function(data){
						$.messager.progress("close");
						if(data.status == "0"){
							$.messager.alert("系统消息","数据处理成功","info",function(){
								$grid.datagrid("reload");
							});
						}else{
							$.messager.alert("系统消息",data.errMsg,"error");
						}
					},"json");
				}
			});
		
	}
</script>
<n:initpage title="电子钱包数据处理！">
	<n:center>
		<div id="tb" >
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:9%">卡类型：</td >
						<td class="tableright" style="width:15%"><input id="cardType" name="cardType" type="text" class="textinput"/></td>
						<td class="tableleft" style="width:9%">卡号：</td>
						<td class="tableright" style="width:18%"><input id="cardNo" name="pay.cardNo" type="text" class="textinput"/></td>
						<td class="tableleft" style="width:9%">业务流水号：</td >
						<td class="tableright" style="width:18%"><input id="dealNo" name="pay.dealNo" type="text" class="textinput"/></td>
					</tr>
					<tr>
						
						<td class="tableleft">交易起始时间：</td>
						<td class="tableright" ><input id="payStartDate" name="payStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">交易结束时间：</td>
						<td class="tableright">
							<input id="payEndDate" name="payEndDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/>
						</td>
						<td style="text-align:left;" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						    <a data-options="iconCls:'icon-viewInfo',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="walletProcess()">处理</a>
						    <!-- <a data-options="iconCls:'icon-save',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toCreateTask();">任务生成</a> -->
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="电子钱包数据信息"></table>
	</n:center>
</n:initpage>