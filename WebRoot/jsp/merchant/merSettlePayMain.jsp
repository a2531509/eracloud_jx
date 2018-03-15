<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>商户结算审核</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var totalAmt=0.00;
		var totalThAmt=0.00;
		var totalStlAmt=0.00;
		var totalNum=0;
		var totalThNum=0;
		var totalFee=0.00;
		function setValue(vTxt) {
	       $('#merchantId').combobox('setValue', vTxt);
	    }
		function checkEndTime(){  
		    var startTime=$("#startDate").val();  
		    var start=new Date(startTime.replace("-", "/").replace("-", "/"));  
		    var endTime=$("#endDate").val(); 
		    var end=new Date(endTime.replace("-", "/").replace("-", "/")); 
		    if(start>end){  
		        return false;  
		    }  
		    return true;  
		} 
		$(function() {
			//结算状态
			$("#stlState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'2',codeName:"已导出"},{codeValue:'9',codeName:"已支付"}]
			});

			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantSettle/merchantSettleAction!toSettlementAudit.action",
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				pageList:[100, 500, 1000, 2000, 5000],
				autoRowHeight:true,
				fitColumns: true,
				showFooter: true,
				scrollbarSize:0,
				columns : [ [ 
								{field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
								{field:'STL_DATE',title:'结算日期',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'MERCHANT_ID',title:'商户编号',sortable:true,width : parseInt($(this).width() * 0.09)},
								{field:'MERCHANT_NAME',title:'商户名称',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'DEAL_NUM',title:'总笔数',sortable:true,width : parseInt($(this).width() * 0.04)},
								{field:'DEAL_AMT',title:'总金额',sortable:true,width : parseInt($(this).width() * 0.04), formatter:formatAmt},
								{field:'DEAL_FEE',title:'总服务费',sortable:true,width : parseInt($(this).width() * 0.05), formatter:formatAmt},
								{field:'STL_AMT',title:'结算金额',sortable:true,width : parseInt($(this).width() * 0.05), formatter:formatAmt},
								{field:'STL_STATE',title:'结算状态',sortable:true,width : parseInt($(this).width() * 0.04)},
								{field:'BANK_ID',title:'开户银行',sortable:true,width : parseInt($(this).width() * 0.08)},
					            {field:'BANK_ACC_NO',title:'银行账号',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'BEGIN_DATE',title:'开始时间',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'END_DATE',title:'结束时间',sortable:true,width : parseInt($(this).width() * 0.06)}
				              ]],
				              toolbar:'#tb',
				              onCheck:function(index,data){
				            	  totalAmt=parseFloat(totalAmt)+parseFloat(data.DEAL_AMT);
				            	  totalThAmt=parseFloat(totalThAmt)+parseFloat(data.TH_AMT);
				            	  totalStlAmt=parseFloat(totalStlAmt)+parseFloat(data.STL_AMT);
				            	  totalFee=parseFloat(totalFee)+parseFloat(data.DEAL_FEE);
				            	  totalNum=parseFloat(totalNum)+parseFloat(data.DEAL_NUM);
				            	  totalThNum=parseFloat(totalThNum)+parseFloat(data.TH_NUM);
				            	  $('#dg').datagrid('reloadFooter',[
				            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),DEAL_NUM : totalNum,DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_NUM : totalThNum,TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
				            	                                ]);
				              },
				              onUncheck:function(index,data){
				            	  totalAmt=parseFloat(totalAmt)-parseFloat(data.DEAL_AMT);
				            	  totalThAmt=parseFloat(totalThAmt)-parseFloat(data.TH_AMT);
				            	  totalStlAmt=parseFloat(totalStlAmt)-parseFloat(data.STL_AMT);
				            	  totalNum=parseFloat(totalNum)-parseFloat(data.DEAL_NUM);
				            	  totalThNum=parseFloat(totalThNum)-parseFloat(data.TH_NUM);
				            	  totalFee=parseFloat(totalFee)-parseFloat(data.DEAL_FEE);
				            	  $('#dg').datagrid('reloadFooter',[
				            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),DEAL_NUM : totalNum,DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_NUM : totalThNum,TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
				            	                                ]);
				              },
				              onCheckAll:function(rows){
				            	  totalAmt=0.00;
				      			  totalThAmt=0.00;
				      			  totalStlAmt=0.00;
				      			  totalFee=0.00;
				      			  totalNum=0;
				      			  totalThNum=0;
				            	  for(var i=0;i<rows.length;i++){
				            		  totalAmt=parseFloat(totalAmt)+parseFloat(rows[i].DEAL_AMT);
				            		  totalThAmt=parseFloat(totalThAmt)+parseFloat(rows[i].TH_AMT);
					            	  totalStlAmt=parseFloat(totalStlAmt)+parseFloat(rows[i].STL_AMT);
					            	  totalNum=parseFloat(totalNum)+parseFloat(rows[i].DEAL_NUM);
					            	  totalThNum=parseFloat(totalThNum)+parseFloat(rows[i].TH_NUM);
					            	  totalFee=parseFloat(totalFee)+parseFloat(rows[i].DEAL_FEE);
					            	  $('#dg').datagrid('reloadFooter',[
					            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),DEAL_NUM : totalNum,DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_NUM : totalThNum,TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
					            	                                ]);
				            	  }
				              },
				              onUncheckAll:function(rows){
				            	  for(var i=0;i<rows.length;i++){
				            		  totalAmt=parseFloat(totalAmt)-parseFloat(rows[i].DEAL_AMT);
				            		  totalThAmt=parseFloat(totalThAmt)-parseFloat(rows[i].TH_AMT);
					            	  totalStlAmt=parseFloat(totalStlAmt)-parseFloat(rows[i].STL_AMT);
					            	  totalNum=parseFloat(totalNum)-parseFloat(rows[i].DEAL_NUM);
					            	  totalThNum=parseFloat(totalThNum)-parseFloat(rows[i].TH_NUM);
					            	  totalFee=parseFloat(totalFee)-parseFloat(rows[i].DEAL_FEE);
					            	  $('#dg').datagrid('reloadFooter',[
					            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),DEAL_NUM : totalNum,DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_NUM : totalThNum,TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
					            	                                ]);
				            	  }
				              },
				              onLoadSuccess:function(data){
				            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			 });
			var pager = $dg.datagrid("getPager");
			pager.pagination({
				buttons:$("#zhuguanPwdDiv")
			});
		});
		function query(){
			totalAmt=0.00;
			totalThAmt=0.00;
			totalStlAmt=0.00;
			totalFee=0.00;
			totalNum=0;
			totalThNum=0;
			if(!checkEndTime()){
				parent.$.messager.show({
					title :'系统消息',
					msg : '您输入起始日期大于结束日期，请重新输入！',
					timeout : 1000 * 3
    			});
				return false;
			}
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				merchantId:$("#merchantId").val(),
				startDate:$("#startDate").val(),
				endDate:$("#endDate").val(),
				stlState:$("#stlState").combobox('getValue')
			});
		}
		
		function viewRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
				if(rows.length==1){
					$.modalDialog({
						title:"交易m明细预览",
						fit:true,
						maximized:true,
						closable:false,
						iconCls:"icon-viewInfo",
						href:"jsp/merchant/merSettleView.jsp?stlSumNo=" + rows[0].SETTLEID,
						buttons:[{
							text:"导出结算明细",iconCls:"icon-execel",
							handler:function(){
								exportClrConsumeMx();
							}
						},{
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
		
		//预览merchantRateViewInfo.jsp
		function viewRowsOpenDlg_BAK(){
			var rows = $dg.datagrid('getChecked');
			if(rows.length==1){
				parent.$.modalDialog({
					title : "预览结算信息",
					width : 650,
					height : 500,
					resizable:true,
					href : "jsp/merchant/merSettleView.jsp",
					onLoad:function(){
						var f = parent.$.modalDialog.handler.find("#dg");
						f.datagrid({
							url : "/merchantSettle/merchantSettleAction!viewSettlementAudit.action?stlSumNo="+rows[0].SETTLEID,
							width : $(this).width() - 0.1,
							height : $(this).height() - 45,
							pagination:false,
							rownumbers:true,
							border:true,
							fit:true,
							singleSelect:false,
							checkOnSelect:true,
							striped:true,
							autoRowHeight:true,
							showFooter: true,
							columns : [ [ 	{field:'CARD_TYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.2)},
											{field:'TR_CODE',title:'交易代码',sortable:true,width : parseInt($(this).width() * 0.2)},
											{field:'ACC_KIND_NAME',title:'账户类型',sortable:true,width : parseInt($(this).width() * 0.2)},
											{field:'TR_NUM',title:'交易笔数',sortable:true,width : parseInt($(this).width() * 0.18)},
											{field:'TR_AMT',title:'交易金额',sortable:true,width : parseInt($(this).width() * 0.19), formatter:formatAmt},
											{field:'OTH_FEE',title:'其他费用',sortable:true,width : parseInt($(this).width() * 0.18)}
							              ]],
							              onLoadSuccess:function(data){
							            	  if(data.status != 0){
							            		 $.messager.alert('系统消息',data.errMsg,'error');
							            	  }
							              }
						 });
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
			
		}
		
		function formatAmt(s, n) {
			if(isNaN(n) || n < 0 || n >= 20){
				n = 2;
			}
			
			s = parseFloat((s + "").replace(/[^\d\.-]/g, ""));
			
			if(isNaN(s)){
				s = 0;
			}
			
			s = s.toFixed(n);

			var l = (s + "").split(".")[0].split("").reverse();
			
			var r = s.split(".")[1];
			
			var t = "";
			
			for(i = 0; i < l.length; i ++ ) {  
				t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length && l[i + 1] != "-" ? "," : "");
			}
			
			return t.split("").reverse().join("") + "." + r; 
		}
		
		function autoCom(){
            if($("#merchantId").val() == ""){
                $("#merchantName").val("");
            }
            $("#merchantId").autocomplete({
                position: {my:"left top",at:"left bottom",of:"#merchantId"},
                source: function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
                        response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                    },'json');
                },
                select: function(event,ui){
                      $('#merchantId').val(ui.item.label);
                    $('#merchantName').val(ui.item.value);
                    return false;
                },
                  focus:function(event,ui){
                    return false;
                  }
            }); 
        }
		
		function payRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
			var stlSumNo="";
			if (rows.length>0) {
				if($("#bankSheetNo").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入银行回单编号！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				for(var i=0;i<rows.length;i++){
					if(i==rows.length-1){
						stlSumNo=stlSumNo+rows[i].SETTLEID;
					}else{
						stlSumNo=stlSumNo+rows[i].SETTLEID+"|";
					}
					
				}
				$.ajax({
					url:"/merchantSettle/merchantSettleAction!saveSettlementPayment.action?stlSumNo="+stlSumNo+"&bankSheetNo="+$("#bankSheetNo").val(),
					success: function(rsp){
						rsp = eval('('+rsp+')');
						parent.$.messager.show({
							title : rsp.title,
							msg : rsp.message,
							timeout : 1000 * 2
						});
						$("#bankSheetNo").val('');
						query();
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function autoCom(){
            if($("#merchantId").val() == ""){
                $("#merchantName").val("");
            }
            $("#merchantId").autocomplete({
                position: {my:"left top",at:"left bottom",of:"#merchantId"},
                source: function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
                        response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                    },'json');
                },
                select: function(event,ui){
                      $('#merchantId').val(ui.item.label);
                    $('#merchantName').val(ui.item.value);
                    return false;
                },
                  focus:function(event,ui){
                    return false;
                  }
            }); 
        }
		
		function autoComByName(){
            if($("#merchantName").val() == ""){
                $("#merchantId").val("");
            }
            $("#merchantName").autocomplete({
                source:function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
                        response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                    },'json');
                },
                select: function(event,ui){
                    $('#merchantId').val(ui.item.value);
                    $('#merchantName').val(ui.item.label);
                    return false;
                },
                focus: function(event,ui){
                    return false;
                }
            }); 
        }
        $(document).keydown(function (event){ 
            if(event.keyCode == 112){
                basePersonalinfoquery();
                event.preventDefault(); 
            }else if(event.keyCode == 115){
                addOrEditBasePersonal("1");
                event.preventDefault(); 
            }else{
                return true;
            }
        });
        
	</script>
	
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户结算</strong></span>进行支付!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input type="text" name="merchantId" id="merchantId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright">
							<input  id="startDate" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/>
						</td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright">
							<input id="endDate" type="text" name="endDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">结算状态：</td >
						<td class="tableright">
							<input id="stlState" class="easyui-combobox easyui-validatebox" name="stlState" style="width:174px;" />
						</td>
						<td class="tableright" colspan="6">
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="merpaymentView">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo"  plain="false" onclick="viewRowsOpenDlg();">预览</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="结算信息"></table>
	  		<div id="zhuguanPwdDiv">
	  			<table>
		  			<tr>
					 	<th  width="150px" align="right">回单编号：</th>
						<td class="tableright" colspan="7"><input id="bankSheetNo" type="text" class="textinput  easyui-validatebox" name="bankSheetNo"   style="width:120px;cursor:pointer;"  />
						<shiro:hasPermission name="merpaymentSave">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-payment"  plain="false" onclick="payRowsOpenDlg();">支付</a>
						</shiro:hasPermission>
						</td>
					</tr>
	  			</table>
	  		</div>
	  </div>
  </body>
</html>
